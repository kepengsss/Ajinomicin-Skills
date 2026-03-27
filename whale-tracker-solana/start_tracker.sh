#!/bin/bash
# Start Whale Tracker

echo "🐋 Starting Solana Whale Tracker..."
echo ""

# Check Python
if ! command -v python3 &> /dev/null; then
    echo "❌ Python3 not found. Please install Python 3.8+"
    exit 1
fi

# Check dependencies
echo "📦 Installing/Checking dependencies..."
pip3 install aiohttp solders solana websockets requests > /dev/null 2>&1

# Create environment file if not exists
if [ ! -f ".env" ]; then
    echo "⚙️ Creating .env template..."
    cat > .env << EOF
# Telegram Configuration
TELEGRAM_BOT_TOKEN=your_bot_token_here
TELEGRAM_CHAT_ID=your_chat_id_here

# RPC Configuration (optional override)
# SOLANA_RPC=https://api.mainnet-beta.solana.com
# SOLANA_WS=wss://api.mainnet-beta.solana.com
EOF
    echo "✅ Created .env file. Please edit with your Telegram credentials."
fi

# Load environment
if [ -f ".env" ]; then
    set -a
    source .env
    set +a
fi

# Start tracker
echo "🚀 Starting tracker..."
python3 whale_tracker.py

# If interrupted
echo ""
echo "👋 Tracker stopped."