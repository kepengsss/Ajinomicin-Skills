#!/bin/bash
# Startup script for Trading Analytics Skill

echo "📈 Starting Trading Analytics..."
echo "================================"

# Check Python
if ! command -v python3 &> /dev/null; then
    echo "❌ Python3 not found. Please install Python 3.8+"
    exit 1
fi

# Install dependencies
echo "📦 Installing dependencies..."
pip3 install aiohttp requests pandas numpy > /dev/null 2>&1

# Copy config if not exists
if [ ! -f "config.json" ]; then
    echo "⚙️ Creating config file..."
    cp config.example.json config.json
    echo "✅ Created config.json. Please edit with your settings."
fi

# Check Telegram config
if grep -q '"bot_token": ""' config.json; then
    echo "⚠️ Telegram bot token not configured"
    echo "   Set TELEGRAM_BOT_TOKEN environment variable or edit config.json"
fi

# Start analytics
echo "🚀 Starting Trading Analytics..."
python3 trading_analytics.py