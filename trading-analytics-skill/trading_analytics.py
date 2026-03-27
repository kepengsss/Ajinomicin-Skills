#!/usr/bin/env python3
"""
Trading Analytics Skill
Price tracking, technical indicators, market sentiment, portfolio performance
"""

import asyncio
import json
import time
from datetime import datetime, timedelta
from typing import Dict, List, Optional, Tuple
import aiohttp
import pandas as pd
import numpy as np
import requests
from dataclasses import dataclass

# Configuration
class Config:
    # API endpoints
    COINGECKO_API = "https://api.coingecko.com/api/v3"
    BINANCE_API = "https://api.binance.com/api/v3"
    MEXC_API = "https://api.mexc.com/api/v3"
    
    # Trading bot integration
    TRADING_BOT_API = "http://localhost:8000"  # Your trading bot API
    
    # Telegram
    TELEGRAM_BOT_TOKEN = ""
    TELEGRAM_CHAT_ID = ""
    
    # Analysis intervals
    CHECK_INTERVAL = 60  # seconds
    REPORT_INTERVAL = 3600  # 1 hour
    
    # Alert thresholds
    PRICE_CHANGE_THRESHOLD = 5.0  # % change for alerts
    VOLUME_THRESHOLD = 2.0  # volume spike multiplier

@dataclass
class PriceAlert:
    symbol: str
    current_price: float
    target_price: float
    change_percent: float
    alert_type: str  # breakout, support, resistance
    timestamp: datetime

@dataclass
class TechnicalIndicator:
    symbol: str
    timeframe: str
    williams_r: float
    rsi: float
    macd: float
    moving_avg_20: float
    moving_avg_50: float
    volume_24h: float
    trend: str  # bullish, bearish, neutral

class TradingAnalytics:
    def __init__(self):
        self.config = Config()
        self.session = None
        self.price_history = {}  # symbol -> list of prices
        self.alerts = []
        self.indicators = {}
        self.portfolio_stats = {}
        
        print("[TradingAnalytics] Initializing...")
    
    async def init(self):
        """Initialize connections"""
        self.session = aiohttp.ClientSession()
    
    async def close(self):
        """Close connections"""
        if self.session:
            await self.session.close()
    
    async def get_crypto_price(self, symbol: str) -> Optional[float]:
        """Get current crypto price"""
        try:
            # Coingecko for most coins
            url = f"{self.config.COINGECKO_API}/simple/price"
            params = {
                "ids": symbol.lower(),
                "vs_currencies": "usd"
            }
            
            async with self.session.get(url, params=params) as resp:
                if resp.status == 200:
                    data = await resp.json()
                    if symbol.lower() in data:
                        return data[symbol.lower()]["usd"]
            
            # Fallback to Binance for trading pairs
            url = f"{self.config.BINANCE_API}/ticker/price"
            params = {"symbol": symbol.upper()}
            
            async with self.session.get(url, params=params) as resp:
                if resp.status == 200:
                    data = await resp.json()
                    return float(data["price"])
            
            return None
        except Exception as e:
            print(f"Error getting price for {symbol}: {e}")
            return None
    
    async def get_price_history(self, symbol: str, hours: int = 24) -> List[float]:
        """Get historical prices for analysis"""
        try:
            # Binance historical data
            url = f"{self.config.BINANCE_API}/klines"
            params = {
                "symbol": symbol.upper(),
                "interval": "1h",
                "limit": hours
            }
            
            async with self.session.get(url, params=params) as resp:
                if resp.status == 200:
                    data = await resp.json()
                    prices = [float(item[4]) for item in data]  # Close prices
                    return prices
            
            return []
        except Exception as e:
            print(f"Error getting history for {symbol}: {e}")
            return []
    
    def calculate_williams_r(self, prices: List[float], period: int = 14) -> float:
        """Calculate Williams %R indicator (Larry Williams style)"""
        if len(prices) < period:
            return 0.0
        
        highest = max(prices[-period:])
        lowest = min(prices[-period:])
        current = prices[-1]
        
        williams_r = ((highest - current) / (highest - lowest)) * -100
        return williams_r
    
    def calculate_rsi(self, prices: List[float], period: int = 14) -> float:
        """Calculate RSI indicator"""
        if len(prices) < period + 1:
            return 50.0
        
        changes = [prices[i] - prices[i-1] for i in range(1, len(prices))]
        
        gains = [change for change in changes if change > 0]
        losses = [-change for change in changes if change < 0]
        
        avg_gain = sum(gains[-period:]) / period if len(gains) >= period else 0
        avg_loss = sum(losses[-period:]) / period if len(losses) >= period else 0
        
        if avg_loss == 0:
            return 100.0
        
        rs = avg_gain / avg_loss
        rsi = 100 - (100 / (1 + rs))
        return rsi
    
    def calculate_macd(self, prices: List[float]) -> Tuple[float, float]:
        """Calculate MACD (12,26,9)"""
        if len(prices) < 26:
            return 0.0, 0.0
        
        # EMA 12
        ema12 = pd.Series(prices).ewm(span=12).mean().iloc[-1]
        # EMA 26
        ema26 = pd.Series(prices).ewm(span=26).mean().iloc[-1]
        
        macd = ema12 - ema26
        signal = pd.Series([macd]).ewm(span=9).mean().iloc[-1]
        
        return macd, signal
    
    def analyze_trend(self, prices: List[float]) -> str:
        """Analyze market trend"""
        if len(prices) < 10:
            return "neutral"
        
        # Simple trend detection
        recent_change = prices[-1] - prices[-10]
        
        if recent_change > 0:
            return "bullish"
        elif recent_change < 0:
            return "bearish"
        else:
            return "neutral"
    
    async def calculate_technical_indicators(self, symbol: str):
        """Calculate all technical indicators for a symbol"""
        prices = await self.get_price_history(symbol, 48)
        
        if not prices:
            return None
        
        williams_r = self.calculate_williams_r(prices)
        rsi = self.calculate_rsi(prices)
        macd, signal = self.calculate_macd(prices)
        ma20 = pd.Series(prices).rolling(20).mean().iloc[-1]
        ma50 = pd.Series(prices).rolling(50).mean().iloc[-1]
        trend = self.analyze_trend(prices)
        
        indicator = TechnicalIndicator(
            symbol=symbol,
            timeframe="1h",
            williams_r=williams_r,
            rsi=rsi,
            macd=macd,
            moving_avg_20=ma20,
            moving_avg_50=ma50,
            volume_24h=0.0,  # Would need volume data
            trend=trend
        )
        
        self.indicators[symbol] = indicator
        return indicator
    
    async check_price_alerts(self, symbol: str, current_price: float):
        """Check for price alerts based on thresholds"""
        if symbol not in self.price_history:
            self.price_history[symbol] = []
        
        self.price_history[symbol].append(current_price)
        
        # Keep only last 100 prices
        if len(self.price_history[symbol]) > 100:
            self.price_history[symbol] = self.price_history[symbol][-100:]
        
        # Calculate price change
        if len(self.price_history[symbol]) >= 10:
            prev_price = self.price_history[symbol][-10]
            change_percent = ((current_price - prev_price) / prev_price) * 100
            
            if abs(change_percent) >= self.config.PRICE_CHANGE_THRESHOLD:
                alert = PriceAlert(
                    symbol=symbol,
                    current_price=current_price,
                    target_price=prev_price,
                    change_percent=change_percent,
                    alert_type="breakout",
                    timestamp=datetime.now()
                )
                self.alerts.append(alert)
                
                # Send alert
                await self.send_price_alert(alert)
    
    async def send_price_alert(self, alert: PriceAlert):
        """Send price alert via Telegram"""
        if not self.config.TELEGRAM_BOT_TOKEN or not self.config.TELEGRAM_CHAT_ID:
            print(f"[ALERT] {alert.symbol}: {alert.change_percent:.2f}% change")
            return
        
        try:
            direction = "UP" if alert.change_percent > 0 else "DOWN"
            message = f"📈 **PRICE ALERT** 🚨\n\n"
            message += f"**Symbol:** {alert.symbol}\n"
            message += f"**Current:** ${alert.current_price:.4f}\n"
            message += f"**Change:** {alert.change_percent:.2f}% {direction}\n"
            message += f"**Type:** {alert.alert_type}\n"
            message += f"**Time:** {alert.timestamp.strftime('%Y-%m-%d %H:%M:%S')}"
            
            url = f"https://api.telegram.org/bot{self.config.TELEGRAM_BOT_TOKEN}/sendMessage"
            payload = {
                "chat_id": self.config.TELEGRAM_CHAT_ID,
                "text": message,
                "parse_mode": "Markdown"
            }
            
            async with self.session.post(url, json=payload) as resp:
                if resp.status != 200:
                    print(f"Failed to send alert: {await resp.text()}")
        except Exception as e:
            print(f"Error sending alert: {e}")
    
    async def get_portfolio_stats(self):
        """Get portfolio performance from trading bot"""
        try:
            url = f"{self.config.TRADING_BOT_API}/stats"
            
            async with self.session.get(url) as resp:
                if resp.status == 200:
                    data = await resp.json()
                    
                    stats = {
                        "total_trades": data.get("total_trades", 0),
                        "win_rate": data.get("win_rate", 0),
                        "profit_factor": data.get("profit_factor", 0),
                        "total_profit": data.get("total_profit", 0),
                        "total_loss": data.get("total_loss", 0),
                        "active_positions": data.get("active_positions", 0)
                    }
                    
                    self.portfolio_stats = stats
                    return stats
            
            return {}
        except Exception as e:
            print(f"Error getting portfolio stats: {e}")
            return {}
    
    async def generate_report(self):
        """Generate comprehensive trading report"""
        report = {
            "timestamp": datetime.now().isoformat(),
            "price_alerts": len(self.alerts),
            "indicators": {},
            "portfolio": self.portfolio_stats,
            "recommendations": []
        }
        
        # Add indicator summaries
        for symbol, indicator in self.indicators.items():
            report["indicators"][symbol] = {
                "williams_r": indicator.williams_r,
                "rsi": indicator.rsi,
                "trend": indicator.trend
            }
            
            # Generate recommendations
            if indicator.williams_r < -80:  # Overbought (Williams %R)
                report["recommendations"].append(f"{symbol}: Consider selling (Williams %R: {indicator.williams_r:.1f})")
            elif indicator.williams_r > -20:  # Oversold
                report["recommendations"].append(f"{symbol}: Consider buying (Williams %R: {indicator.williams_r:.1f})")
            
            if indicator.rsi > 70:  # Overbought (RSI)
                report["recommendations"].append(f"{symbol}: RSI overbought ({indicator.rsi:.1f})")
            elif indicator.rsi < 30:  # Oversold
                report["recommendations"].append(f"{symbol}: RSI oversold ({indicator.rsi:.1f})")
        
        return report
    
    async def send_report(self, report: Dict):
        """Send report via Telegram"""
        if not self.config.TELEGRAM_BOT_TOKEN or not self.config.TELEGRAM_CHAT_ID:
            # Print report
            print("\n📊 TRADING REPORT 📊")
            print(f"Alerts: {report['price_alerts']}")
            print(f"Portfolio Win Rate: {report['portfolio'].get('win_rate', 0)}%")
            print("Recommendations:")
            for rec in report["recommendations"]:
                print(f"  - {rec}")
            return
        
        try:
            message = f"📊 **TRADING ANALYTICS REPORT** 📊\n\n"
            message += f"**Time:** {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n"
            message += f"**Price Alerts:** {report['price_alerts']}\n\n"
            
            if report['portfolio']:
                message += f"**Portfolio Stats:**\n"
                message += f"  Win Rate: {report['portfolio'].get('win_rate', 0)}%\n"
                message += f"  Profit Factor: {report['portfolio'].get('profit_factor', 0):.2f}\n"
                message += f"  Active Positions: {report['portfolio'].get('active_positions', 0)}\n\n"
            
            if report['recommendations']:
                message += f"**Recommendations:**\n"
                for rec in report['recommendations']:
                    message += f"  • {rec}\n"
            
            url = f"https://api.telegram.org/bot{self.config.TELEGRAM_BOT_TOKEN}/sendMessage"
            payload = {
                "chat_id": self.config.TELEGRAM_CHAT_ID,
                "text": message,
                "parse_mode": "Markdown"
            }
            
            async with self.session.post(url, json=payload) as resp:
                if resp.status != 200:
                    print(f"Failed to send report: {await resp.text()}")
        except Exception as e:
            print(f"Error sending report: {e}")
    
    async def monitor_symbols(self, symbols: List[str]):
        """Main monitoring loop for trading analytics"""
        print(f"[Monitoring] Tracking {len(symbols)} symbols")
        
        last_report_time = datetime.now()
        
        while True:
            try:
                current_time = datetime.now()
                
                # Check prices and calculate indicators
                for symbol in symbols:
                    price = await self.get_crypto_price(symbol)
                    if price:
                        await self.check_price_alerts(symbol, price)
                        await self.calculate_technical_indicators(symbol)
                
                # Get portfolio stats
                await self.get_portfolio_stats()
                
                # Generate report periodically
                if (current_time - last_report_time).seconds >= self.config.REPORT_INTERVAL:
                    report = await self.generate_report()
                    await self.send_report(report)
                    last_report_time = current_time
                
                # Print status
                print(f"[{current_time.strftime('%H:%M:%S')}] Active alerts: {len(self.alerts)} | Indicators: {len(self.indicators)}")
                
                await asyncio.sleep(self.config.CHECK_INTERVAL)
                
            except Exception as e:
                print(f"Error in monitoring loop: {e}")
                await asyncio.sleep(30)

async def main():
    """Main function"""
    print("=" * 50)
    print("📈 TRADING ANALYTICS SKILL 📈")
    print("=" * 50)
    print("Features:")
    print("1. Price tracking & alerts")
    print("2. Technical indicator calculation")
    print("3. Market sentiment analysis")
    print("4. Portfolio performance tracking")
    print("=" * 50)
    
    # Get symbols to monitor
    symbols_input = input("Enter symbols to monitor (comma separated): ").strip()
    if not symbols_input:
        symbols = ["bitcoin", "ethereum", "solana"]  # Default
    else:
        symbols = [s.strip() for s in symbols_input.split(",")]
    
    # Create analytics instance
    analytics = TradingAnalytics()
    
    try:
        await analytics.init()
        await analytics.monitor_symbols(symbols)
        
    except Keyboard