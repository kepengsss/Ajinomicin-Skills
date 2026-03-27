---
name: whale-tracker-solana
description: Track whale activities on Solana with auto wallet rotation detection. Monitor transactions, detect new wallets, and send Telegram alerts for Pump.fun, GMGN, Raydium, Jupiter, and all Solana platforms.
metadata:
  {
    "openclaw":
      {
        "emoji": "🐋",
        "requires": { 
          "bins": ["python3", "pip3"],
          "python_packages": ["aiohttp", "solders", "solana", "websockets", "requests"]
        },
        "install":
          [
            {
              "id": "python-deps",
              "kind": "pip",
              "packages": ["aiohttp", "solders", "solana", "websockets", "requests"],
              "label": "Install Python dependencies",
            },
            {
              "id": "create-config",
              "kind": "exec",
              "command": "cp config.example.json config.json && echo 'Please edit config.json with your settings'",
              "workdir": "./",
              "label": "Create config file",
            },
          ],
      },
  }
---

# 🐋 Solana Whale Tracker Skill

Track whale activities on Solana with auto wallet rotation detection. Monitor all platforms (Pump.fun, GMGN, Raydium, Jupiter, etc.) and get real-time Telegram alerts.

## Features

- **Whale Transaction Tracking**: Monitor all transactions from target whale
- **Auto Wallet Rotation Detection**: Auto-detect when whale changes wallets
- **Multi-Platform Support**: Pump.fun, GMGN, Raydium, Jupiter, Orca, Meteora, SPL tokens
- **Real-time Notifications**: Telegram alerts for buys and wallet rotations
- **24/7 Monitoring**: Run as systemd service on VPS

## Quick Start

### Installation
```bash
# The skill will auto-install dependencies
# Just activate it when needed
```

### Basic Usage
```bash
# Start monitoring a whale wallet
python3 whale_tracker.py
```

### Setup Config
Edit `config.json`:
```json
{
  "telegram": {
    "bot_token": "your_bot_token",
    "chat_id": "your_chat_id"
  },
  "whale_wallet": "8x4h...",
  "check_interval": 10,
  "min_sol_for_rotation": 10.0
}
```

## When to Use This Skill

Use this skill when the user wants to:

- Track whale activities on Solana
- Monitor specific whale wallet addresses
- Get alerts when whale makes buys
- Auto-track when whale changes wallets
- Monitor Pump.fun, GMGN, Raydium, Jupiter activities

## Tools

The skill provides these functions:

### 1. Start Monitoring
```python
# Start tracking a whale
python3 whale_tracker.py
# Will prompt for whale wallet address
```

### 2. Check Status
```bash
# Check if tracker is running
systemctl status whale-tracker
```

### 3. View Logs
```bash
# View recent logs
journalctl -u whale-tracker -n 20
```

## Commands Reference

### Manual Start
```bash
cd /path/to/skill
python3 whale_tracker.py
```

### Systemd Service (VPS)
```bash
# Start service
sudo systemctl start whale-tracker

# Enable auto-start
sudo systemctl enable whale-tracker

# Check status
sudo systemctl status whale-tracker
```

## Configuration

### Environment Variables
```bash
# Optional: Override RPC endpoints
export SOLANA_RPC="https://api.mainnet-beta.solana.com"
export SOLANA_WS="wss://api.mainnet-beta.solana.com"
```

### Config File (config.json)
```json
{
  "initial_wallet": "whale_wallet_address",
  "telegram": {
    "bot_token": "",
    "chat_id": ""
  },
  "rpc_endpoints": {
    "solana": "https://api.mainnet-beta.solana.com"
  },
  "monitoring": {
    "check_interval_seconds": 10,
    "min_sol_for_rotation": 10.0,
    "notify_on_buy": true,
    "notify_on_wallet_rotation": true
  }
}
```

## Notification Examples

### Buy Alert
```
🐋 WHALE ALERT 🚨

Wallet: 8x4h...9j2k
Token: 7y3g...8h1j
Type: Memecoin 🚀
Amount: 5.42 SOL
Platform: Pump.fun 🔥
Action: Token Transfer
TX: https://solscan.io/tx/...
Time: 2026-03-27 06:32:15 UTC
```

### Wallet Rotation
```
🔄 WALLET ROTATION DETECTED 🔄

Old Wallet: 8x4h...9j2k
New Wallet: 7y3g...8h1j
Transfer Amount: 15.75 SOL
TX: https://solscan.io/tx/...
Time: 2026-03-27 06:35:22 UTC

⚠️ Now tracking new wallet!
```

## Platform Detection

The skill detects transactions on:
- 🔥 **Pump.fun** - Memecoin launches
- 🎮 **GMGN** - Gaming & token projects
- 🦉 **Raydium** - DEX trading
- 🪐 **Jupiter** - Aggregator swaps
- 🐋 **Orca** - DEX
- 🌠 **Meteora** - DEX
- 💰 **SPL Token** - All token transfers

## Safety Rules

- Never share private keys or sensitive data
- Always verify whale addresses before tracking
- Use dedicated Telegram bot for notifications
- Monitor RPC usage to avoid rate limits
- Keep config files secure

## Troubleshooting

### Common Issues

1. **RPC Timeout**: Change to faster RPC endpoint
2. **Telegram Notifications**: Verify bot token and chat ID
3. **Python Dependencies**: Run `pip install -r requirements.txt`
4. **Wallet Not Found**: Verify wallet address is correct

### Logs
```bash
# View detailed logs
journalctl -u whale-tracker -f

# Check for errors
journalctl -u whale-tracker --since "5 minutes ago"
```

## Deployment

### VPS Deployment
Use the included `deploy.sh` script:
```bash
chmod +x deploy.sh
sudo ./deploy.sh
```

### Manual VPS Setup
```bash
# Copy files to VPS
scp -r whale_tracker.py config.json user@vps:/opt/whale-tracker/

# Install systemd service
sudo cp whale-tracker.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable whale-tracker
sudo systemctl start whale-tracker
```

## License

MIT - Free to use and modify

## Version

v1.0.0 - Initial release
2026-03-27