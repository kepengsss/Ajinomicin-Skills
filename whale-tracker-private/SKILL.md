---
name: whale-tracker-private
description: PRIVATE Whale Tracker for Ajinomicin only (Telegram ID: 1473275947). Track whale activities on Solana with auto wallet rotation detection.
metadata:
  {
    "openclaw":
      {
        "emoji": "🔐🐋",
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
          ],
      },
  }
---

# 🔐 PRIVATE Whale Tracker Skill

**EXCLUSIVE FOR AJINOMICIN ONLY** (Telegram ID: 1473275947)

Track whale activities on Solana with auto wallet rotation detection. This bot will ONLY work for Ajinomicin.

## 🔒 SECURITY FEATURES

- **Hardcoded Authorization**: Only Telegram ID `1473275947` can use this bot
- **Private Notifications**: All alerts sent ONLY to Ajinomicin's Telegram
- **No Public Access**: Rejects all unauthorized users immediately
- **Encrypted Config**: Sensitive data protected

## 🎯 Features

- **Exclusive Access**: Only Ajinomicin can use this bot
- **Whale Transaction Tracking**: Monitor all transactions from target whale
- **Auto Wallet Rotation Detection**: Auto-detect when whale changes wallets
- **Multi-Platform Support**: Pump.fun, GMGN, Raydium, Jupiter, all Solana platforms
- **Private Notifications**: Telegram alerts sent ONLY to Ajinomicin
- **24/7 Monitoring**: Run as systemd service on VPS

## 🚀 Quick Start

### Installation
```bash
# Dependencies will auto-install
# Bot will auto-check authorization on startup
```

### Usage
```bash
# Method 1: Run with Telegram ID
python3 whale_tracker_auth.py 1473275947

# Method 2: Run and input whale wallet
python3 whale_tracker_auth.py
```

### Authorized User
```
👑 Owner: Ajinomicin
🔐 Telegram ID: 1473275947
✅ Status: AUTHORIZED
```

## ⚙️ Configuration

### Environment Variables
```bash
# Telegram Bot Token (for notifications)
export TELEGRAM_BOT_TOKEN="your_bot_token"

# Ajinomicin's Telegram ID (hardcoded, cannot change)
export TELEGRAM_USER_ID="1473275947"
```

### Bot Token Setup
1. Create bot via @BotFather
2. Get bot token
3. Set `TELEGRAM_BOT_TOKEN` environment variable
4. Bot will ONLY send to Ajinomicin (1473275947)

## 🛡️ Authorization Flow

```
1. User attempts to use bot
2. Bot checks Telegram ID
3. IF ID == 1473275947 → ✅ AUTHORIZED (Ajinomicin)
4. ELSE → ❌ ACCESS DENIED
5. All notifications sent ONLY to 1473275947
```

## 💬 Commands

### Start Monitoring
```bash
# With pre-defined whale wallet
python3 whale_tracker_auth.py 1473275947 <WHALE_WALLET>

# Interactive mode
python3 whale_tracker_auth.py
```

### Check Authorization
```bash
# Will show authorization status
python3 whale_tracker_auth.py test
```

## 📱 Notification Examples

### Buy Alert (Only to Ajinomicin)
```
🐋 **WHALE ALERT** 🚨

**Wallet:** `8x4h...9j2k`
**Token:** `7y3g...8h1j`
**Type:** Memecoin 🚀
**Amount:** `5.42 SOL`
**Platform:** Pump.fun 🔥
**Action:** Token Transfer
**TX:** https://solscan.io/tx/...

👑 *Private Bot for Ajinomicin*
```

### Wallet Rotation (Only to Ajinomicin)
```
🔄 **WALLET ROTATION DETECTED** 🔄

**Old Wallet:** `8x4h...9j2k`
**New Wallet:** `7y3g...8h1j`
**Transfer Amount:** `15.75 SOL`
**TX:** https://solscan.io/tx/...

⚠️ **Now tracking new wallet!**
👑 *Private Bot for Ajinomicin*
```

## 🚫 Unauthorized Access Response

If someone else tries to use the bot:
```
❌ ACCESS DENIED

Your ID: 1234567890
Authorized ID: 1473275947 (Ajinomicin)

This bot is private for Ajinomicin only.
```

## 🔧 Technical Details

### Authorization Check
- Hardcoded in `AUTHORIZED_TELEGRAM_ID = "1473275947"`
- Checked on every bot interaction
- Cannot be bypassed or changed

### Security Measures
1. **ID Validation**: Strict Telegram ID matching
2. **Private Messaging**: All notifications to owner only
3. **No Public API**: No endpoints for unauthorized access
4. **Encrypted Storage**: Sensitive configs protected

## 📊 Platform Detection

The bot detects transactions on:
- 🔥 **Pump.fun** - Memecoin launches
- 🎮 **GMGN** - Gaming & token projects  
- 🦉 **Raydium** - DEX trading
- 🪐 **Jupiter** - Aggregator swaps
- 🐋 **Orca** - DEX
- 🌠 **Meteora** - DEX
- 💰 **SPL Token** - All token transfers

## 🏢 Deployment

### VPS Setup
```bash
# Deploy with authorization
chmod +x deploy_private.sh
sudo ./deploy_private.sh
```

### Systemd Service
Service will auto-start with:
- User: `whaleuser`
- Environment: `TELEGRAM_BOT_TOKEN`
- Authorization: Hardcoded to Ajinomicin

## 🆘 Support

### Authorized Support
- **Owner**: Ajinomicin (1473275947)
- **Contact**: Via authorized Telegram only
- **Issues**: Only owner can report issues

### Unauthorized Access
- **Response**: Immediate denial
- **Logging**: All attempts logged
- **Action**: No further interaction

## 📄 License

**PRIVATE LICENSE** - Exclusive use by Ajinomicin only

## ⚠️ Disclaimer

This bot is:
- **Exclusive**: Only for Ajinomicin
- **Private**: No public access
- **Secure**: Hardcoded authorization
- **Monitored**: All usage logged

**Version**: 1.0.0-PRIVATE  
**Owner**: Ajinomicin (1473275947)  
**Created**: 2026-03-27