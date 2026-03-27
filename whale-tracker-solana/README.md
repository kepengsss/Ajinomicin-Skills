# 🐋 Solana Whale Tracker Skill

OpenClaw skill untuk track aktivitas whale di Solana dengan auto wallet rotation detection.

## 🎯 Fitur

1. **Whale Transaction Tracking** - Monitor semua transaksi dari wallet whale
2. **Auto Wallet Rotation Detection** - Deteksi otomatis saat whale ganti wallet
3. **Multi-Platform Support** - Pump.fun, GMGN, Raydium, Jupiter, Orca, semua platform Solana
4. **Real-time Notifications** - Telegram alerts untuk setiap buy dan wallet rotation
5. **24/7 Monitoring** - Run sebagai systemd service di VPS

## 📦 Installation

### Sebagai OpenClaw Skill
```bash
# Copy ke skills directory
cp -r skill_whale_tracker ~/.openclaw/skills/whale-tracker-solana
```

### Manual Installation
```bash
# Install dependencies
pip3 install aiohttp solders solana websockets requests

# Setup config
cp config.example.json config.json
# Edit config.json dengan settings Anda
```

## ⚙️ Configuration

Edit `config.json`:
```json
{
  "initial_wallet": "8x4h...your_whale_wallet",
  "telegram": {
    "bot_token": "your_bot_token",
    "chat_id": "your_chat_id"
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

## 🚀 Usage

### Basic Usage
```bash
python3 whale_tracker.py
# Akan prompt untuk input wallet whale
```

### Dengan Config
```bash
# Edit dulu config.json dengan wallet target
# Lalu run
python3 whale_tracker.py
```

### Sebagai Systemd Service (VPS)
```bash
# Deploy ke VPS
chmod +x deploy.sh
sudo ./deploy.sh

# Management commands
sudo systemctl status whale-tracker
sudo systemctl restart whale-tracker
sudo journalctl -u whale-tracker -f
```

## 📊 Platform Detection

Skill ini mendeteksi transaksi di:
- 🔥 **Pump.fun** - Memecoin launches
- 🎮 **GMGN** - Gaming & token projects  
- 🦉 **Raydium** - DEX trading
- 🪐 **Jupiter** - Aggregator swaps
- 🐋 **Orca** - DEX
- 🌠 **Meteora** - DEX
- 💰 **SPL Token** - Semua token transfers

## 🔔 Notification Examples

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
```

### Wallet Rotation
```
🔄 WALLET ROTATION DETECTED 🔄
Old Wallet: 8x4h...9j2k
New Wallet: 7y3g...8h1j
Transfer Amount: 15.75 SOL
TX: https://solscan.io/tx/...
⚠️ Now tracking new wallet!
```

## 🛠️ Management Scripts

Script included:
- `start_tracker.sh` - Startup script
- `deploy.sh` - VPS deployment script
- `monitor.sh` - Status monitoring (auto-generated saat deploy)

## 🐛 Troubleshooting

### 1. RPC Timeout
```bash
# Ganti RPC di config.json
"solana": "https://api.mainnet-beta.solana.com"
```

### 2. Telegram Notifications
1. Cek bot token dan chat ID
2. Pastikan bot sudah di-add ke chat
3. Test: `curl https://api.telegram.org/bot<TOKEN>/getMe`

### 3. Python Dependencies
```bash
pip3 install --upgrade pip
pip3 install aiohttp solders solana websockets requests
```

## 📈 Advanced Features

### Custom Filters
Edit `config.json` untuk customize:
- Minimum SOL amount untuk notifications
- Platform focus (Pump.fun only, atau semua)
- Check interval (5-60 detik)

### Multi-Whale Tracking
Edit code untuk track multiple whales:
```python
# Di whale_tracker.py, ubah:
self.current_wallets = set([initial_wallet])
# Menjadi:
self.current_wallets = set(["wallet1", "wallet2", "wallet3"])
```

## 📄 License

MIT - Free to use and modify

## 👥 Author

Dikembangkan sebagai OpenClaw Skill untuk automasi trading Web3