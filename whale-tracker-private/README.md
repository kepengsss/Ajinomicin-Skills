# 🔐 PRIVATE WHALE TRACKER

**EXCLUSIVE FOR AJINOMICIN ONLY**  
**Telegram ID: 1473275947**

## 🛡️ SECURITY FIRST

Bot ini **hanya bisa digunakan oleh Ajinomicin**. Fitur keamanan:
- ✅ **Hardcoded authorization** - ID Telegram 1473275947
- ✅ **Private notifications** - Hanya ke Ajinomicin
- ✅ **Access denial** - User lain langsung ditolak
- ✅ **Encrypted config** - Data sensitif aman

## 🚀 INSTALLATION

### 1. Install Dependencies
```bash
pip3 install aiohttp solders solana websockets requests
```

### 2. Setup Telegram Bot
```bash
# Buat bot di @BotFather
# Dapatkan bot token
export TELEGRAM_BOT_TOKEN="your_bot_token"

# Telegram ID sudah hardcoded (1473275947)
# Tidak perlu setup lain
```

### 3. Run Bot
```bash
# Method 1: Langsung run
python3 whale_tracker_auth.py

# Method 2: Dengan Telegram ID (verifikasi)
python3 whale_tracker_auth.py 1473275947
```

## 📱 AUTHORIZATION FLOW

```
1. User coba pakai bot
2. Bot cek Telegram ID
3. JIKA ID == 1473275947 → ✅ AJINOMICIN (AUTHORIZED)
4. LAINNYA → ❌ ACCESS DENIED
5. Semua notifikasi HANYA ke 1473275947
```

## 💬 COMMANDS

### Start Monitoring
```bash
# Mode interaktif (akan minta input wallet)
python3 whale_tracker_auth.py

# Dengan wallet spesifik
python3 whale_tracker_auth.py 1473275947 8x4h...wallet_address
```

### Check Authorization
```bash
# Cek status authorization
python3 whale_tracker_auth.py test
```

## 🔔 NOTIFICATION FORMAT

### Buy Alert
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

### Wallet Rotation
```
🔄 **WALLET ROTATION DETECTED** 🔄

**Old Wallet:** `8x4h...9j2k`
**New Wallet:** `7y3g...8h1j`
**Transfer Amount:** `15.75 SOL`
**TX:** https://solscan.io/tx/...

⚠️ **Now tracking new wallet!**
👑 *Private Bot for Ajinomicin*
```

## 🚫 RESPONSE UNTUK USER LAIN

Jika user lain coba pakai:
```
❌ ACCESS DENIED

Your ID: 1234567890
Authorized ID: 1473275947 (Ajinomicin)

This bot is private for Ajinomicin only.
```

## ⚙️ CONFIGURATION

### Environment Variables
```bash
# Bot token (wajib untuk notifications)
export TELEGRAM_BOT_TOKEN="your_bot_token"

# Telegram ID (sudah hardcoded, optional)
export TELEGRAM_USER_ID="1473275947"
```

### RPC Configuration
Default RPC: `https://api.mainnet-beta.solana.com`

Bisa diganti dengan RPC yang lebih cepat:
```python
# Edit di whale_tracker_auth.py
SOLANA_RPC = "https://api.mainnet-beta.solana.com"
```

## 🏢 VPS DEPLOYMENT

### Deploy Script
```bash
# Buat deployment script
cat > deploy_private.sh << 'EOF'
#!/bin/bash
echo "🔐 Deploying PRIVATE Whale Tracker for Ajinomicin"
echo "=============================================="
echo "Owner: Ajinomicin (1473275947)"
echo "Bot will ONLY work for owner"
EOF

chmod +x deploy_private.sh
./deploy_private.sh
```

### Systemd Service
```bash
# Create service file
sudo tee /etc/systemd/system/whale-tracker-private.service << EOF
[Unit]
Description=PRIVATE Whale Tracker (Ajinomicin Only)
After=network.target

[Service]
Type=simple
User=ajinomicin
Environment=TELEGRAM_BOT_TOKEN=your_token
WorkingDirectory=/opt/whale-tracker
ExecStart=/usr/bin/python3 /opt/whale-tracker/whale_tracker_auth.py 1473275947
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF
```

## 🐛 TROUBLESHOOTING

### 1. Authorization Failed
```
❌ ERROR: Telegram ID not provided
```
**Solution**: Run dengan: `python3 whale_tracker_auth.py 1473275947`

### 2. Telegram Notifications Not Working
```
[NOTIFICATION] Whale activity detected!
```
**Solution**: Set `TELEGRAM_BOT_TOKEN` environment variable

### 3. RPC Timeout
```
Error getting transactions: timeout
```
**Solution**: Ganti RPC endpoint di code

### 4. Python Dependencies
```
ModuleNotFoundError: No module named 'aiohttp'
```
**Solution**: `pip3 install aiohttp solders solana websockets requests`

## 📊 PLATFORM SUPPORT

Bot mendeteksi transaksi di:
- 🔥 **Pump.fun** - Memecoin launches
- 🎮 **GMGN** - Gaming & token projects  
- 🦉 **Raydium** - DEX trading
- 🪐 **Jupiter** - Aggregator swaps
- 🐋 **Orca** - DEX
- 🌠 **Meteora** - DEX
- 💰 **SPL Token** - Semua token transfers

## ⚠️ DISCLAIMER

- Bot ini **eksklusif** untuk Ajinomicin
- **Tidak ada public access**
- Semua aktivitas **dilog**
- **Private license** - hanya owner yang boleh pakai

## 👑 OWNER INFO

```
Name: Ajinomicin
Telegram ID: 1473275947
Username: @HolderTokenBerlian
Status: ✅ AUTHORIZED
```

**Version**: 1.0.0-PRIVATE  
**Last Updated**: 2026-03-27  
**License**: PRIVATE - Ajinomicin Only