# 🚀 OpenClaw Skills Package

**Collection of production-ready OpenClaw skills for Web3 automation, trading, and monitoring.**

## 📦 Included Skills

### 1. 🔐 **Private Whale Tracker** (`whale-tracker-private/`)
- **Description**: Exclusive whale tracking for Solana with auto wallet rotation detection
- **Features**: 
  - Track whale activities on all Solana platforms
  - Auto-detect wallet rotations
  - Private notifications (Telegram ID whitelist)
  - Pump.fun, GMGN, Raydium, Jupiter support
- **Status**: ✅ Production Ready
- **Authorization**: Hardcoded for owner only

### 2. 💳 **Solana Pay Manager** (`solana-pay/`)
- **Description**: Solana wallet manager with Jupiter swaps & Moonshot monitoring
- **Features**:
  - Send SOL/USDC
  - Swap tokens via Jupiter API
  - Top-up Avici Visa
  - Moonshot balance monitoring
- **Status**: ✅ Ready (needs API keys)

### 3. 🦞 **PolyHub Trading Suite** (`polyhub-skills/`)
- **Description**: Polymarket copy-trading automation suite
- **Skills**:
  - `polyhub_discover` - Browse trader leaderboards
  - `polyhub_copy` - Auto-copy trading
  - `polyhub_account` - Portfolio management
- **Status**: ✅ Ready (needs PolyHub API key)

### 4. 🐋 **Public Whale Tracker** (`whale-tracker-solana/`)
- **Description**: Public version of whale tracker (no authorization)
- **Features**: Same as private version but open to all
- **Status**: ✅ Production Ready

## 🚀 Quick Start

### Installation
```bash
# Clone repository
git clone <this-repo>
cd OpenClaw-Skills-Package

# Install all skills to OpenClaw
./install_all.sh

# Or install individually
./install_skill.sh whale-tracker-private
```

### Skill Installation
```bash
# Each skill has its own setup
cd whale-tracker-private
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# Configure
cp config.example.json config.json
# Edit config.json with your settings
```

## 📁 Repository Structure

```
OpenClaw-Skills-Package/
├── README.md
├── LICENSE
├── install_all.sh
├── install_skill.sh
├── update_all.sh
├── whale-tracker-private/
│   ├── SKILL.md
│   ├── whale_tracker_auth.py
│   ├── requirements.txt
│   └── config.example.json
├── solana-pay/
│   ├── SKILL.md
│   ├── index.js
│   ├── package.json
│   └── config.example.json
├── polyhub-skills/
│   ├── openclaw/
│   │   ├── polyhub_discover/
│   │   ├── polyhub_copy/
│   │   └── polyhub_account/
│   └── README.md
└── whale-tracker-solana/
    ├── SKILL.md
    ├── whale_tracker.py
    └── requirements.txt
```

## ⚙️ Configuration

### Environment Setup
```bash
# Copy environment template
cp .env.example .env

# Edit .env with your API keys
# TELEGRAM_BOT_TOKEN=...
# POLYHUB_API_KEY=...
# SOLANA_PRIVATE_KEY=...
```

### Skill-Specific Config
Each skill has its own `config.example.json`:
1. Copy to `config.json`
2. Edit with your credentials
3. Never commit `config.json` to Git

## 🛠️ Management Scripts

### `install_all.sh`
```bash
# Install all skills to OpenClaw
./install_all.sh
```

### `install_skill.sh <skill-name>`
```bash
# Install specific skill
./install_skill.sh whale-tracker-private
```

### `update_all.sh`
```bash
# Update all skills from source
./update_all.sh
```

### `start_skill.sh <skill-name>`
```bash
# Start a skill
./start_skill.sh whale-tracker-private
```

## 🔧 Dependencies

### System Requirements
- Python 3.8+
- Node.js 16+
- OpenClaw installed
- Git

### Python Packages
```bash
# Core dependencies
pip install aiohttp solders solana websockets requests
```

### Node.js Packages
```bash
# For solana-pay skill
npm install @solana/web3.js @solana/spl-token bs58 cross-fetch
```

## 🚀 Deployment

### Local OpenClaw
```bash
# Install skills locally
cp -r skills/* ~/.openclaw/skills/
```

### VPS Deployment
```bash
# Use deploy scripts in each skill
cd whale-tracker-private
chmod +x deploy.sh
sudo ./deploy.sh
```

### Docker (Optional)
```bash
# Build Docker image
docker build -t openclaw-skills .

# Run with skills
docker run -v ./skills:/skills openclaw-skills
```

## 📊 Skill Matrix

| Skill | Type | Auth Needed | Status | Use Case |
|-------|------|-------------|--------|----------|
| Whale Tracker (Private) | Monitoring | Telegram ID | ✅ | Whale tracking |
| Whale Tracker (Public) | Monitoring | None | ✅ | Public tracking |
| Solana Pay | Wallet | API Keys | ✅ | Wallet management |
| PolyHub Discover | Trading | None | ✅ | Trader discovery |
| PolyHub Copy | Trading | API Key | ✅ | Auto-copy trading |
| PolyHub Account | Trading | API Key | ✅ | Portfolio management |

## 🔐 Security

### Private Skills
- `whale-tracker-private`: Hardcoded authorization
- Telegram ID whitelist
- No public API endpoints

### API Keys
- Store in `.env` file (gitignored)
- Never commit sensitive data
- Use environment variables

### Best Practices
1. **Never share** `config.json` files
2. **Use .gitignore** for sensitive files
3. **Rotate API keys** regularly
4. **Monitor access logs**

## 🆘 Troubleshooting

### Common Issues

1. **Skill not loading**
   ```bash
   # Check OpenClaw skills directory
   ls ~/.openclaw/skills/
   
   # Restart OpenClaw
   openclaw restart
   ```

2. **Python dependencies**
   ```bash
   # Reinstall dependencies
   pip install -r requirements.txt --upgrade
   ```

3. **Telegram notifications**
   ```bash
   # Test bot token
   curl https://api.telegram.org/bot<TOKEN>/getMe
   ```

### Logs
```bash
# Check skill logs
tail -f /var/log/whale-tracker.log

# OpenClaw logs
journalctl -u openclaw -f
```

## 📈 Performance

### Resource Requirements
- **CPU**: Minimal (monitoring is lightweight)
- **RAM**: 100-500MB per skill
- **Storage**: 50-100MB per skill
- **Network**: RPC calls for monitoring

### Optimization Tips
1. Use dedicated RPC endpoints
2. Adjust check intervals
3. Monitor rate limits
4. Use caching where possible

## 🤝 Contributing

### Adding New Skills
1. Create skill directory
2. Add `SKILL.md` with metadata
3. Include `requirements.txt` or `package.json`
4. Add to `install_all.sh`
5. Update this README

### Reporting Issues
1. Check existing issues
2. Create detailed bug report
3. Include logs and config (sanitized)
4. Suggest fix if possible

## 📄 License

MIT License - See [LICENSE](LICENSE) file for details.

## 👥 Authors

- **Ajinomicin** (@HolderTokenBerlian) - Project owner
- **Flux AI Assistant** - Development & automation

## 🔗 Links

- **OpenClaw Docs**: https://docs.openclaw.ai
- **ClawHub**: https://clawhub.com
- **GitHub Repository**: [Private Link]
- **Support**: Contact repository owner

## 🎯 Roadmap

### Phase 1 ✅
- [x] Package existing skills
- [x] Create installation scripts
- [x] Add documentation

### Phase 2 🚧
- [ ] Add Docker support
- [ ] Create web dashboard
- [ ] Add more Web3 skills

### Phase 3 📅
- [ ] Multi-chain support
- [ ] AI-enhanced features
- [ ] Community contributions

---

**Last Updated**: 2026-03-27  
**Version**: 1.0.0  
**OpenClaw Version**: Compatible with latest