#!/usr/bin/env python3
"""
Whale Tracker dengan Authorization - Hanya Ajinomicin (1473275947) yang bisa pakai
"""

import asyncio
import json
import sys
import os
from datetime import datetime
from typing import Dict, List, Optional, Set
import aiohttp
from solders.pubkey import Pubkey
from solana.rpc.async_api import AsyncClient
import requests

# ==================== AUTHORIZATION SYSTEM ====================
AUTHORIZED_TELEGRAM_ID = "1473275947"  # Ajinomicin
AUTHORIZED_USER_NAME = "Ajinomicin"

def check_authorization():
    """Check if the current user is authorized"""
    # Get Telegram ID from environment or arguments
    telegram_id = os.getenv('TELEGRAM_USER_ID')
    
    if not telegram_id and len(sys.argv) > 1:
        # Check if first argument is Telegram ID
        if sys.argv[1].isdigit() and len(sys.argv[1]) == 10:
            telegram_id = sys.argv[1]
    
    if not telegram_id:
        print("❌ ERROR: Telegram ID not provided")
        print("Usage: python3 whale_tracker_auth.py <TELEGRAM_ID> [WHALE_WALLET]")
        print(f"Authorized ID: {AUTHORIZED_TELEGRAM_ID} ({AUTHORIZED_USER_NAME})")
        sys.exit(1)
    
    if telegram_id != AUTHORIZED_TELEGRAM_ID:
        print(f"❌ ACCESS DENIED")
        print(f"Your ID: {telegram_id}")
        print(f"Authorized ID: {AUTHORIZED_TELEGRAM_ID} ({AUTHORIZED_USER_NAME})")
        print("This bot is private for Ajinomicin only.")
        sys.exit(1)
    
    print(f"✅ AUTHORIZED: {AUTHORIZED_USER_NAME}")
    print(f"🔐 Telegram ID: {telegram_id}")
    return telegram_id

# ==================== WHALE TRACKER ====================
class Config:
    SOLANA_RPC = "https://api.mainnet-beta.solana.com"
    CHECK_INTERVAL = 10
    TELEGRAM_BOT_TOKEN = ""
    TELEGRAM_CHAT_ID = AUTHORIZED_TELEGRAM_ID  # Always send to Ajinomicin

class WhaleTrackerAuth:
    def __init__(self, initial_wallet: str, telegram_id: str):
        self.config = Config()
        self.initial_wallet = initial_wallet
        self.telegram_id = telegram_id
        self.current_wallets = set([initial_wallet])
        self.tracked_wallets = set([initial_wallet])
        self.tracked_transactions = set()
        self.session = None
        self.client = None
        
        # Stats
        self.total_transactions = 0
        self.wallet_rotations = 0
        
        print(f"[WhaleTracker] Owner: {AUTHORIZED_USER_NAME}")
        print(f"[WhaleTracker] Tracking wallet: {initial_wallet}")
    
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
                "params": [wallet, {"limit": 10}]
            }
            
            async with self.session.post(url, json=payload) as resp:
                if resp.status == 200:
                    data = await resp.json()
                    if 'result' in data:
                        return data['result']
            return []
        except Exception as e:
            print(f"Error getting transactions: {e}")
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
            print(f"Error getting transaction: {e}")
            return None
    
    def analyze_token_transaction(self, tx_details: Dict) -> Dict:
        """Analyze transaction untuk extract token information"""
        result = {
            'platform': 'unknown',
            'token_address': None,
            'action': 'unknown',
            'amount': 0,
            'is_memecoin': False
        }
        
        try:
            instructions = tx_details.get('transaction', {}).get('message', {}).get('instructions', [])
            
            for instruction in instructions:
                program_id = instruction.get('programId', '')
                
                if 'pump' in program_id.lower() or 'fun' in program_id.lower():
                    result['platform'] = 'pump.fun'
                    result['is_memecoin'] = True
                elif 'gmg' in program_id.lower():
                    result['platform'] = 'gmgn'
                elif 'raydium' in program_id.lower():
                    result['platform'] = 'raydium'
                elif 'jupiter' in program_id.lower():
                    result['platform'] = 'jupiter'
                elif 'orca' in program_id.lower():
                    result['platform'] = 'orca'
                elif 'meteora' in program_id.lower():
                    result['platform'] = 'meteora'
                elif 'token' in program_id.lower():
                    result['platform'] = 'spl_token'
                elif instruction.get('program') == 'system':
                    if instruction.get('parsed', {}).get('type') == 'transfer':
                        info = instruction.get('parsed', {}).get('info', {})
                        result['amount'] = info.get('lamports', 0) / 1_000_000_000
                        result['action'] = 'sol_transfer'
            
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
            print(f"Error analyzing transaction: {e}")
            return result
    
    async def send_notification(self, wallet: str, signature: str, amount: float, token_info: Dict):
        """Send notification via Telegram (only to Ajinomicin)"""
        if not self.config.TELEGRAM_BOT_TOKEN:
            print(f"[NOTIFICATION] Whale activity detected!")
            print(f"  Wallet: {wallet[:8]}...{wallet[-8:]}")
            print(f"  Amount: {amount:.4f} SOL")
            print(f"  Platform: {token_info.get('platform', 'unknown')}")
            print(f"  Action: {token_info.get('action', 'unknown')}")
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
            message += f"\n\n👑 *Private Bot for {AUTHORIZED_USER_NAME}*"
            
            url = f"https://api.telegram.org/bot{self.config.TELEGRAM_BOT_TOKEN}/sendMessage"
            payload = {
                "chat_id": self.config.TELEGRAM_CHAT_ID,  # Always Ajinomicin
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
        """Detect jika whale ganti wallet"""
        try:
            txs = await self.get_wallet_transactions(wallet)
            for tx in txs:
                signature = tx['signature']
                if signature in self.tracked_transactions:
                    continue
                
                tx_details = await self.get_transaction_details(signature)
                if not tx_details:
                    continue
                
                try:
                    for instruction in tx_details.get('transaction', {}).get('message', {}).get('instructions', []):
                        if 'program' in instruction and instruction['program'] == 'system':
                            if instruction.get('parsed', {}).get('type') == 'transfer':
                                info = instruction.get('parsed', {}).get('info', {})
                                if info.get('source') == wallet:
                                    amount = info.get('lamports', 0) / 1_000_000_000
                                    new_wallet = info.get('destination', '')
                                    
                                    if amount > 10 and new_wallet not in self.tracked_wallets:
                                        self.wallet_rotations += 1
                                        self.tracked_wallets.add(new_wallet)
                                        self.current_wallets.add(new_wallet)
                                        
                                        print(f"[WALLET ROTATION] Whale ganti wallet!")
                                        print(f"  Old: {wallet[:8]}...{wallet[-8:]}")
                                        print(f"  New: {new_wallet[:8]}...{new_wallet[-8:]}")
                                        
                                        # Send rotation notification
                                        await self.send_wallet_rotation_notification(wallet, new_wallet, amount, signature)
                                        return new_wallet
                except:
                    continue
        except Exception as e:
            print(f"Error detecting wallet rotation: {e}")
        
        return None
    
    async def send_wallet_rotation_notification(self, old_wallet: str, new_wallet: str, amount: float, signature: str):
        """Send wallet rotation notification"""
        if not self.config.TELEGRAM_BOT_TOKEN:
            print(f"[WALLET ROTATION] {old_wallet[:8]}... -> {new_wallet[:8]}... ({amount} SOL)")
            return
        
        try:
            message = f"🔄 **WALLET ROTATION DETECTED** 🔄\n\n"
            message += f"**Old Wallet:** `{old_wallet[:8]}...{old_wallet[-8:]}`\n"
            message += f"**New Wallet:** `{new_wallet[:8]}...{new_wallet[-8:]}`\n"
            message += f"**Transfer Amount:** `{amount:.4f} SOL`\n"
            message += f"**TX:** https://solscan.io/tx/{signature}\n"
            message += f"**Time:** {datetime.utcnow().strftime('%Y-%m-%d %H:%M:%S UTC')}\n\n"
            message += f"⚠️ **Now tracking new wallet!**\n"
            message += f"👑 *Private Bot for {AUTHORIZED_USER_NAME}*"
            
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
    
    async def analyze_transaction(self, tx: Dict, wallet: str):
        """Analyze transaction untuk detect whale activity"""
        signature = tx['signature']
        
        if signature in self.tracked_transactions:
            return
        
        tx_details = await self.get_transaction_details(signature)
        if not tx_details:
            return
        
        is_buy = False
        amount = 0
        
        try:
            for instruction in tx_details.get('transaction', {}).get('message', {}).get('instructions', []):
                if 'program' in instruction and instruction['program'] == 'system':
                    if instruction.get('parsed', {}).get('type') == 'transfer':
                        info = instruction.get('parsed', {}).get('info', {})
                        if info.get('destination') == wallet:
                            amount = info.get('lamports', 0) / 1_000_000_000
                            is_buy = True
        
        except Exception as e:
            print(f"Error analyzing transaction {signature}: {e}")
        
        if is_buy and amount > 0:
            self.total_transactions += 1
            self.tracked_transactions.add(signature)
            
            token_info = self.analyze_token_transaction(tx_details)
            await self.send_notification(wallet, signature, amount, token_info)
    
    async def monitor_whale(self):
        """Main monitoring loop"""
        print(f"\n[START] Monitoring whale untuk {AUTHORIZED_USER_NAME}")
        print(f"[INFO] Whale wallet: {self.initial_wallet}")
        print(f"[INFO] Check interval: {self.config.CHECK_INTERVAL} detik")
        print("-" * 50)
        
        while True:
            try:
                print(f"\n[{datetime.utcnow().strftime('%H:%M:%S')}] Checking {len(self.current_wallets)} wallets...")
                
                for wallet in list(self.current_wallets):
                    txs = await self.get_wallet_transactions(wallet)
                    for tx in txs:
                        await self.analyze_transaction(tx, wallet)
                    
                    new_wallet = await self.detect_wallet_rotation(wallet)
                    if new_wallet:
                        print(f"[INFO] Added new wallet to tracking: {new_wallet[:8]}...")
                
                print(f"[STATS] Total TX: {self.total_transactions} | Rotations: {self.wallet_rotations} | Wallets: {len(self.tracked_wallets)}")
                
                await asyncio.sleep(self.config.CHECK_INTERVAL)
                
            except Exception as e:
                print(f"Error in monitoring loop: {e}")
                await asyncio.sleep(30)

async def main():
    """Main function"""
    print("=" * 50)
    print(f"🔐 PRIVATE WHALE TRACKER - {AUTHORIZED_USER_NAME}")
    print("=" * 50)
    
    # Step 1: Authorization check
    telegram_id = check_authorization()
    
    # Step 2: Get whale wallet
    whale_wallet = None
    if len(sys.argv) > 2:
        whale_wallet = sys.argv[2]
    else:
        print(f"\n👑 Welcome {AUTHORIZED_USER_NAME}!")
        whale_wallet = input("Masukkan wallet address whale: ").strip()
    
    if not whale_wallet:
        print("Wallet address diperlukan!")
        return
    
    # Create tracker
    tracker = WhaleTrackerAuth(whale_wallet, telegram_id)
    
    try:
        await tracker.init()
        await tracker.monitor_whale()
        
    except KeyboardInterrupt:
        print(f"\n[STOP] Monitoring stopped for {AUTHORIZED_USER_NAME}")
    except Exception as e:
        print(f"[ERROR] Fatal error: {e}")
    finally:
        await tracker.close()
        print(f"[EXIT] Clean shutdown - {AUTHORIZED_USER_NAME}")

if __name__ == "__main__":
    asyncio.run(main())