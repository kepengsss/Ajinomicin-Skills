# 📈 Trading Analytics Skill

Advanced trading analytics for crypto with price tracking, technical indicators, and portfolio performance monitoring.

## 🎯 Features

### 1. Price Tracking & Alerts
- Real-time price monitoring for multiple cryptocurrencies
- Customizable alert thresholds (price change, volume spikes)
- Telegram notifications for breakouts and significant changes

### 2. Technical Indicators (Larry Williams Style)
- **Williams %R** - Primary indicator for overbought/oversold
- **RSI** - Relative Strength Index (14-period)
- **MACD** - Moving Average Convergence Divergence
- **Moving Averages** - MA20 & MA50 for trend detection
- **Volume Analysis** - Volume spike detection

### 3. Market Sentiment Analysis
- Trend analysis (bullish/bearish/neutral)
- Market condition assessment
- Correlation analysis between symbols

### 4. Portfolio Performance Tracking
- Integration with trading bots (MEXC bot from earlier)
- Win rate, profit factor calculation
- Active position monitoring
- Performance alerts and recommendations

## 🚀 Installation

### Quick Install
```bash
pip3 install aiohttp requests pandas numpy

# Run skill
python3 trading_analytics.py
```

### OpenClaw Skill Installation
```bash
# Copy to skills directory
cp -r trading-analytics-skill ~/.openclaw/skills/trading-analytics
```

## ⚙️ Configuration

### Basic Config
```json
{
  "symbols": ["BTC", "ETH", "SOL", "DOGE"],
  "telegram": {
    "bot_token": "your_bot_token",
    "chat_id": "your_chat_id"
  },
  "alert_thresholds": {
    "price_change": 5.0,
    "volume_spike": 2.0
  },
  "report_interval": 3600
}
```

### Environment Variables
```bash
export TELEGRAM_BOT_TOKEN="your_bot_token"
export TELEGRAM_CHAT_ID="your_chat_id"

# Trading bot integration (optional)
export TRADING_BOT_API="http://localhost:8000"
```

## 📊 Technical Indicators Explained

### Williams %R (Larry Williams)
- **Purpose**: Identify overbought/oversold conditions
- **Range**: -100 to 0
- **Overbought**: Values below -80 (consider selling)
- **Oversold**: Values above -20 (consider buying)
- **Formula**: ((Highest - Current) / (Highest - Lowest)) × -100

### RSI (Relative Strength Index)
- **Purpose**: Measure momentum
- **Range**: 0 to 100
- **Overbought**: Above 70
- **Oversold**: Below 30
- **Calculation**: Based on average gains/losses over 14 periods

### MACD
- **Purpose**: Identify trend changes
- **Components**: EMA12, EMA26, Signal line (EMA9)
- **Signal**: MACD above Signal = bullish, below = bearish

## 🔔 Alert Examples

### Price Breakout Alert
```
📈 PRICE ALERT 🚨

Symbol: BTC
Current: $65,432.10
Change: +5.42% UP
Type: breakout
Time: 2026-03-27 14:30:15
```

### Technical Indicator Alert
```
📊 TECHNICAL ALERT

Symbol: ETH
Williams %R: -85.2
Status: Overbought
Recommendation: Consider selling
RSI: 72.5 (also overbought)
```

### Portfolio Alert
```
💰 PORTFOLIO UPDATE

Win Rate: 68% → 72% (+4%)
Profit Factor: 1.65 → 1.80 (+0.15)
Active Positions: 3 → 5 (+2)
```

## 🛠️ Usage Examples

### Monitor Specific Symbols
```bash
python3 trading_analytics.py
# Enter: BTC,ETH,SOL,DOGE
```

### Generate Report Only
```bash
python3 trading_analytics.py --report
```

### Custom Interval
```bash
python3 trading_analytics.py --interval 30 --symbols BTC,ETH
```

### Integration with MEXC Trading Bot
```bash
# Set trading bot API in config
export TRADING_BOT_API="http://localhost:8000"
python3 trading_analytics.py
```

## 📈 Williams %R Trading Strategy

### Larry Williams Approach
1. **Entry**: Williams %R > -20 (oversold) + confirmation from other indicators
2. **Exit**: Williams %R < -80 (overbought) or profit target reached
3. **Position Size**: Based on risk tolerance and market conditions
4. **Risk Management**: Strict stop-losses and position sizing

### Combined Analysis
- Use Williams %R as primary indicator
- Confirm with RSI and MACD
- Check volume for validity
- Consider market trend context

## 🏢 Deployment

### VPS Deployment
```bash
# Create systemd service
sudo tee /etc/systemd/system/trading-analytics.service << EOF
[Unit]
Description=Trading Analytics Service
After=network.target

[Service]
Type=simple
User=trading
WorkingDirectory=/opt/trading-analytics
ExecStart=/usr/bin/python3 /opt/trading-analytics/trading_analytics.py
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable trading-analytics
sudo systemctl start trading-analytics
```

### Docker Deployment
```bash
docker build -t trading-analytics .
docker run -d --name trading-analytics \
  -v ./config.json:/app/config.json \
  trading-analytics
```

## 🐛 Troubleshooting

### Common Issues

1. **API Rate Limits**
   ```bash
   # Increase check interval
   "check_interval": 120
   ```

2. **Missing Price Data**
   ```bash
   # Try different symbol formats
   "symbols": ["bitcoin", "BTC"]
   ```

3. **Indicator Calculation Errors**
   ```bash
   # Ensure enough historical data
   python3 trading_analytics.py --history 48
   ```

4. **Telegram Notifications**
   ```bash
   # Test bot token
   curl https://api.telegram.org/bot<TOKEN>/getMe
   ```

## 📋 Performance Metrics

### What Gets Tracked
- Price change percentage
- Volume spikes
- Indicator values (Williams %R, RSI, MACD)
- Trend direction
- Portfolio win rate & profit factor
- Alert frequency and types

### Report Metrics
- Daily/hourly summaries
- Best/worst performing symbols
- Market trend analysis
- Trading bot performance
- Alert effectiveness

## 🔗 Integration Points

### With Existing Skills
1. **Whale Tracker**: Correlate whale activity with price movements
2. **Solana Pay**: Monitor SOL price for wallet management
3. **PolyHub Skills**: Compare prediction markets with crypto prices
4. **MEXC Trading Bot**: Direct performance monitoring

### External APIs
- CoinGecko (primary price source)
- Binance API (trading pairs)
- Trading bot custom API
- Telegram notifications

## 📄 License

MIT License - Free for commercial and personal use

## 👥 Author

Developed as OpenClaw Skill for crypto trading automation

## 🚀 Roadmap

### Future Features
- Social sentiment analysis (Twitter, Discord)
- News impact scoring
- Advanced pattern recognition
- Multi-timeframe analysis
- AI-based prediction models