#!/usr/bin/env python3
"""
Whale Tracker untuk Solana (Pump.fun)
Track transaksi whale dan auto-detect wallet rotation
"""

import asyncio
import json
import time
from datetime import datetime
from typing import Dict, List, Optional, Set
import aiohttp
from solders.pubkey import Pubkey
from solana.rpc.async_api import AsyncClient
import websockets
import requests

# Konfigurasi
class Config:
    # RPC endpoints
    SOLANA_RPC = "https://api.mainnet-beta.solana.com"
    SOLANA_WS = "wss://api.mainnet-beta.solana.com"
    
    # Pump.fun API
    PUMPFUN_API = "https://frontend-api.pump.fun"
    
    # DEX Screener untuk harga
    DEX_SCREENER_API = "https://api.dexscreener.com/latest/dex/pairs/solana"
    
    # Interval check (detik)
    CHECK_INTERVAL = 10
    
    # Telegram config (akan diisi dari env)
    TELEGRAM_BOT_TOKEN = ""
    TELEGRAM_CHAT_ID = ""

class WhaleTracker:
    def __init__(self, initial_wallet: str):
        self.config = Config()
        self.initial_wallet = initial_wallet
        self.current_wallets = set([initial_wallet])
        self.tracked_wallets = set([initial_wallet])
        self.tracked_transactions = set()
        self.session = None
        self.client = None
        
        # Stats
        self.total_transactions = 0
        self.wallet_rotations = 0
        self.last_notification = {}
        
        print(f"[WhaleTracker] Mulai tracking wallet: {initial_wallet}")
    
    async def init(self):
        """Initialize connections"""
        self.session = aiohttp.ClientSession()
        self.client = AsyncClient(self.config.SOLANA_RPC)
    
    async def close(self):
        """Close connections"""
        if self.session:
            await self.session.close()
        if self.client:
            await self.client.close()
    
    async def get_wallet_transactions(self, wallet: str) -> List[Dict]:
        """Get recent transactions for a wallet"""
        try:
            url = f"{self.config.SOLANA_RPC}"
            payload = {
                "jsonrpc": "2.0",
                "id": 1,
                "method": "getSignaturesForAddress",
                "params": [
                    wallet,
                    {"limit": 10}
                ]
            }
            
            async with self.session.post(url, json=payload) as resp:
                if resp.status == 200:
                    data = await resp.json()
                    if 'result' in data:
                        return data['result']
            return []
        except Exception as e:
            print(f"Error getting transactions for {wallet}: {e}")
            return []
    
    async def get_transaction_details(self, signature: str) -> Optional[Dict]:
        """Get detailed transaction info"""
        try:
            url = f"{self.config.SOLANA_RPC}"
            payload = {
                "jsonrpc": "2.0",
                "id": 1,
                "method": "getTransaction",
                "params": [
                    signature,
                    {"encoding": "jsonParsed", "maxSupportedTransactionVersion": 0}
                ]
            }
            
            async with self.session.post(url, json=payload) as resp:
                if resp.status == 200:
                    data = await resp.json()
                    if 'result' in data:
                        return data['result']
            return None
        except Exception as e:
            print(f"Error getting transaction {signature}: {e}")
            return None
    
    def analyze_token_transaction(self, tx_details: Dict) -> Dict:
        """Analyze transaction untuk extract token information"""
        result = {
            'platform': 'unknown',
            'token_address': None,
            'token_symbol': None,
            'action': 'unknown',
            'amount': 0,
            'is_memecoin': False
        }
        
        try:
            instructions = tx_details.get('transaction', {}).get('message', {}).get('instructions', [])
            
            # Check platform dari program ID
            for instruction in instructions:
                program_id = instruction.get('programId', '')
                
                # Pump.fun
                if 'pump' in program_id.lower() or 'fun' in program_id.lower():
                    result['platform'] = 'pump.fun'
                    result['is_memecoin'] = True
                
                # GMGN (gaming/token)
                elif 'gmg' in program_id.lower():
                    result['platform'] = 'gmgn'
                
                # Raydium
                elif 'raydium' in program_id.lower():
                    result['platform'] = 'raydium'
                
                # Jupiter
                elif 'jupiter' in program_id.lower():
                    result['platform'] = 'jupiter'
                
                # Orca
                elif 'orca' in program_id.lower():
                    result['platform'] = 'orca'
                
                # Meteora
                elif 'meteora' in program_id.lower():
                    result['platform'] = 'meteora'
                
                # Token Program (SPL)
                elif 'token' in program_id.lower():
                    result['platform'] = 'spl_token'
                
                # System transfer (SOL)
                elif instruction.get('program') == 'system':
                    if instruction.get('parsed', {}).get('type') == 'transfer':
                        info = instruction.get('parsed', {}).get('info', {})
                        result['amount'] = info.get('lamports', 0) / 1_000_000_000
                        result['action'] = 'sol_transfer'
            
            # Try to extract token address
            for instruction in instructions:
                parsed = instruction.get('parsed', {})
                if parsed.get('type') == 'transferChecked':
                    info = parsed.get('info', {})
                    result['token_address'] = info.get('mint')
                    result['action'] = 'token_transfer'
                
                elif parsed.get('type') == 'swap':
                    result['action'] = 'swap'
            
            return result
            
        except Exception as e:
            print(f"Error analyzing token transaction: {e}")
            return result
    
    async def analyze_transaction(self, tx: Dict, wallet: str):
        """Analyze transaction untuk detect whale activity"""
        signature = tx['signature']
        
        # Skip jika sudah diproses
        if signature in self.tracked_transactions:
            return
        
        tx_details = await self.get_transaction_details(signature)
        if not tx_details:
            return
        
        # Check if it's a buy transaction (incoming SOL/transfer)
        is_buy = False
        token_address = None
        amount = 0
        
        try:
            # Analisis sederhana: cari transfer SOL atau token
            for instruction in tx_details.get('transaction', {}).get('message', {}).get('instructions', []):
                if 'program' in instruction and instruction['program'] == 'system':
                    # Transfer SOL
                    if instruction.get('parsed', {}).get('type') == 'transfer':
                        info = instruction.get('parsed', {}).get('info', {})
                        if info.get('destination') == wallet:
                            amount = info.get('lamports', 0) / 1_000_000_000  # Convert to SOL
                            is_buy = True
        
        except Exception as e:
            print(f"Error analyzing transaction {signature}: {e}")
        
        # Jika transaksi beli ditemukan
        if is_buy and amount > 0:
            self.total_transactions += 1
            self.tracked_transactions.add(signature)
            
            # Analyze token transaction details
            token_info = self.analyze_token_transaction(tx_details)
            
            # Prepare notification
            await self.send_notification(wallet, signature, amount, token_info)
    
    async def send_notification(self, wallet: str, signature: str, amount: float, token_info: Dict):
        """Send notification via Telegram"""
        if not self.config.TELEGRAM_BOT_TOKEN or not self.config.TELEGRAM_CHAT_ID:
            print(f"[NOTIFICATION] Whale activity detected!")
            print(f"  Wallet: {wallet[:8]}...{wallet[-8:]}")
            print(f"  Amount: {amount:.4f} SOL")
            platform = token_info.get('platform', 'unknown')
            action = token_info.get('action', 'unknown')
            print(f"  Platform: {platform}")
            print(f"  Action: {action}")
            if token_info.get('token_address'):
                print(f"  Token: {token_info['token_address'][:8]}...")
            print(f"  TX: https://solscan.io/tx/{signature}")
            return
        
        try:
            platform_icons = {
                'pump.fun': '🔥',
                'gmgn': '🎮',
                'raydium': '🦉',
                'jupiter': '🪐',
                'orca': '🐋',
                'meteora': '🌠',
                'spl_token': '💰',
                'unknown': '❓'
            }
            
            platform = token_info.get('platform', 'unknown')
            icon = platform_icons.get(platform, '❓')
            action = token_info.get('action', 'unknown')
            
            message = f"🐋 **WHALE ALERT** 🚨\n\n"
            message += f"**Wallet:** `{wallet[:8]}...{wallet[-8:]}`\n"
            
            if token_info.get('token_address'):
                token_addr = token_info['token_address']
                message += f"**Token:** `{token_addr[:8]}...{token_addr[-8:]}`\n"
                if token_info['is_memecoin']:
                    message += f"**Type:** Memecoin 🚀\n"
            
            message += f"**Amount:** `{amount:.4f} SOL`\n"
            message += f"**Platform:** {platform.title()} {icon}\n"
            message += f"**Action:** {action.replace('_', ' ').title()}\n"
            message += f"**TX:** https://solscan.io/tx/{signature}\n"
            message += f"**Time:** {datetime.utcnow().strftime('%Y-%m-%d %H:%M:%S UTC')}"
            
            url = f"https://api.telegram.org/bot{self.config.TELEGRAM_BOT_TOKEN}/sendMessage"
            payload = {
                "chat_id": self.config.TELEGRAM_CHAT_ID,
                "text": message,
                "parse_mode": "Markdown",
                "disable_web_page_preview": False
            }
            
            async with self.session.post(url, json=payload) as resp:
                if resp.status != 200:
                    print(f"Failed to send Telegram notification: {await resp.text()}")
        except Exception as e:
            print(f"Error sending notification: {e}")
    
    async def detect_wallet_rotation(self, wallet: str):
        """Detect jika whale ganti wallet (sederhana: cari transfer besar ke wallet baru)"""
        try:
            txs = await self.get_wallet_transactions(wallet)
            for tx in txs:
                signature = tx['signature']
                if signature in self.tracked_transactions:
                    continue
                
                tx_details = await self.get_transaction_details(signature)
                if not tx_details:
                    continue
                
                # Cari transfer besar (>10 SOL) ke wallet baru
                try:
                    for instruction in tx_details.get('transaction', {}).get('message', {}).get('instructions', []):
                        if 'program' in instruction and instruction['program'] == 'system':
                            if instruction.get('parsed', {}).get('type') == 'transfer':
                                info = instruction.get('parsed', {}).get('info', {})
                                if info.get('source') == wallet:
                                    amount = info.get('lamports', 0) / 1_000_000_000
                                    new_wallet = info.get('destination', '')
                                    
                                    if amount > 10 and new_wallet not in self.tracked_wallets:
                                        # Detected wallet rotation!
                                        self.wallet_rotations += 1
                                        self.tracked_wallets.add(new_wallet)
                                        self.current_wallets.add(new_wallet)
                                        
                                        print(f"[WALLET ROTATION] Whale ganti wallet!")
                                        print(f"  Old: {wallet[:8]}...{wallet[-8:]}")
                                        print(f"  New: {new_wallet[:8]}...{new_wallet[-8:]}")
                                        print(f"  Amount: {amount:.4f} SOL")
                                        print(f"  TX: https://solscan.io/tx/{signature}")
                                        
                                        # Send notification
                                        await self.send_wallet_rotation_notification(wallet, new_wallet, amount, signature)
                                        return new_wallet
                except:
                    continue
        except Exception as e:
            print(f"Error detecting wallet rotation: {e}")
        
        return None
    
    async def send_wallet_rotation_notification(self, old_wallet: str, new_wallet: str, amount: float, signature: str):
        """Send wallet rotation notification"""
        if not self.config.TELEGRAM_BOT_TOKEN or not self.config.TELEGRAM_CHAT_ID:
            print(f"[WALLET ROTATION] {old_wallet[:8]}... -> {new_wallet[:8]}... ({amount} SOL)")
            return
        
        try:
            message = f"🔄 **WALLET ROTATION DETECTED** 🔄\n\n"
            message += f"**Old Wallet:** `{old_wallet[:8]}...{old_wallet[-8:]}`\n"
            message += f"**New Wallet:** `{new_wallet[:8]}...{new_wallet[-8:]}`\n"
            message += f"**Transfer Amount:** `{amount:.4f} SOL`\n"
            message += f"**TX:** https://solscan.io/tx/{signature}\n"
            message += f"**Time:** {datetime.utcnow().strftime('%Y-%m-%d %H:%M:%S UTC')}\n\n"
            message += f"⚠️ **Now tracking new wallet!**"
            
            url = f"https://api.telegram.org/bot{self.config.TELEGRAM_BOT_TOKEN}/sendMessage"
            payload = {
                "chat_id": self.config.TELEGRAM_CHAT_ID,
                "text": message,
                "parse_mode": "Markdown",
                "disable_web_page_preview": False
            }
            
            async with self.session.post(url, json=payload) as resp:
                if resp.status != 200:
                    print(f"Failed to send rotation notification: {await resp.text()}")
        except Exception as e:
            print(f"Error sending rotation notification: {e}")
    
    async def monitor_whale(self):
        """Main monitoring loop"""
        print(f"[START] Monitoring whale dengan wallet: {self.initial_wallet}")
        print(f"[INFO] Check interval: {self.config.CHECK_INTERVAL} detik")
        
        while True:
            try:
                print(f"\n[{datetime.utcnow().strftime('%H:%M:%S')}] Checking {len(self.current_wallets)} wallets...")
                
                # Check each tracked wallet
                for wallet in list(self.current_wallets):
                    # 1. Check for new transactions
                    txs = await self.get_wallet_transactions(wallet)
                    for tx in txs:
                        await self.analyze_transaction(tx, wallet)
                    
                    # 2. Check for wallet rotation
                    new_wallet = await self.detect_wallet_rotation(wallet)
                    if new_wallet:
                        print(f"[INFO] Added new wallet to tracking: {new_wallet[:8]}...")
                
                # Print stats
                print(f"[STATS] Total TX: {self.total_transactions} | Wallet Rotations: {self.wallet_rotations} | Tracked Wallets: {len(self.tracked_wallets)}")
                
                # Wait before next check
                await asyncio.sleep(self.config.CHECK_INTERVAL)
                
            except Exception as e:
                print(f"Error in monitoring loop: {e}")
                await asyncio.sleep(30)  # Wait longer on error

async def main():
    """Main function"""
    print("=" * 50)
    print("🐋 SOLANA WHALE TRACKER 🐋")
    print("=" * 50)
    print("Tracking whale activities on Solana (All platforms)")
    print("\nInstructions:")
    print("1. Masukkan wallet address whale yang ingin di-track")
    print("2. Sistem akan monitor semua transaksi")
    print("3. Auto-detect jika whale ganti wallet")
    print("4. Notifikasi via Telegram (jika dikonfigurasi)")
    print("=" * 50)
    
    # Get whale wallet from user
    whale_wallet = input("Masukkan wallet address whale: ").strip()
    
    if not whale_wallet:
        print("Wallet address diperlukan!")
        return
    
    # Create tracker
    tracker = WhaleTracker(whale_wallet)
    
    try:
        # Initialize
        await tracker.init()
        
        # Start monitoring
        await tracker.monitor_whale()
        
    except KeyboardInterrupt:
        print("\n[STOP] Monitoring stopped by user")
    except Exception as e:
        print(f"[ERROR] Fatal error: {e}")
    finally:
        await tracker.close()
        print("[EXIT] Clean shutdown")

if __name__ == "__main__":
    asyncio.run(main())