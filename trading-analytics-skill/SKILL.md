---
name: trading-analytics
description: Trading analytics with price tracking, technical indicators, market sentiment analysis, and portfolio performance tracking. Supports Williams %R (Larry Williams style), RSI, MACD, and custom alerts.
metadata:
  {
    "openclaw":
      {
        "emoji": "📈",
        "requires": { 
          "bins": ["python3", "pip3"],
          "python_packages": ["aiohttp", "requests", "pandas", "numpy"]
        },
        "install":
          [
            {
              "id": "python-deps",
              "kind": "pip",
              "packages": ["aiohttp", "requests", "pandas", "numpy"],
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

# 📈 Trading Analytics Skill

Advanced trading analytics with price tracking, technical indicators, market sentiment analysis, and portfolio performance tracking. Designed for crypto trading automation with Larry Williams style indicators.

## Features

- **Price Tracking & Alerts**: Real-time price monitoring with customizable alerts
- **Technical Indicators**: Williams %R, RSI, MACD, Moving averages (Larry Williams style)
- **Market Sentiment**: Trend analysis and market condition detection
- **Portfolio Performance**: Track trading bot performance with win rate, profit factor
- **Automated Reports**: Periodic analytics reports with actionable recommendations

## Quick Start

### Installation
```bash
# The skill will auto-install dependencies
# Just activate it when needed
```

### Basic Usage
```bash
python3 trading_analytics.py
```

### Setup Config
Edit `config.json`:
```json
{
  "symbols": ["bitcoin", "ethereum", "solana"],
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

## When to Use This Skill

Use this skill when the user wants to:

- Monitor crypto prices with real-time alerts
- Calculate technical indicators for trading decisions
- Analyze market trends and sentiment
- Track portfolio performance automatically
- Get actionable trading recommendations

## Tools

The skill provides these functions:

### 1. Start Monitoring
```python
# Start tracking symbols
python3 trading_analytics.py
# Will prompt for symbols to monitor
```

### 2. Calculate Indicators
```python
# Get Williams %R, RSI, MACD for any symbol
python3 trading_analytics.py --symbol BTC
```

### 3. Generate Report
```python
# Generate comprehensive trading report
python3 trading_analytics.py --report
```

## Technical Indicators

### Williams %R (Larry Williams Style)
- **Range**: -100 to 0
- **Overbought**: < -80 (consider selling)
- **Oversold**: > -20 (consider buying)
- **Default period**: 14

### RSI (Relative Strength Index)
- **Range**: 0 to 100
- **Overbought**: > 70
- **Oversold**: < 30
- **Default period**: 14

### MACD (Moving Average Convergence Divergence)
- **EMA 12**, **EMA 26**, **Signal 9**
- **Bullish**: MACD > Signal
- **Bearish**: MACD < Signal

### Moving Averages
- **MA 20**: Short-term trend
- **MA 50**: Medium-term trend
- **Trend**: MA20 > MA50 = bullish, MA20 < MA50 = bearish

## Alert Types

### Price Breakout Alert
Triggers when price changes > threshold (default: 5%)
```
📈 PRICE ALERT 🚨
Symbol: BTC
Current: $65,432.10
Change: +5.42% UP
Type: breakout
```

### Technical Indicator Alert
Based on Williams %R or RSI thresholds
```
📊 TECHNICAL ALERT
Symbol: ETH
Williams %R: -85.2 (Overbought)
Recommendation: Consider selling
```

### Portfolio Performance Alert
When win rate or profit factor changes significantly
```
💰 PORTFOLIO ALERT
Win Rate: 72% ↑ (+5%)
Profit Factor: 1.85 ↑ (+0.15)
```

## Configuration

### Environment Variables
```bash
# Telegram configuration
export TELEGRAM_BOT_TOKEN="your_bot_token"
export TELEGRAM_CHAT_ID="your_chat_id"

# Trading bot API (optional)
export TRADING_BOT_API="http://localhost:8000"
```

### Config File (config.json)
```json
{
  "symbols": ["BTC", "ETH", "SOL", "DOGE"],
  "telegram": {
    "bot_token": "",
    "chat_id": ""
  },
  "api_endpoints": {
    "coingecko": "https://api.coingecko.com/api/v3",
    "binance": "https://api.binance.com/api/v3"
  },
  "analysis": {
    "check_interval": 60,
    "report_interval": 3600,
    "price_change_threshold": 5.0,
    "volume_threshold": 2.0
  },
  "indicators": {
    "williams_period": 14,
    "rsi_period": 14,
    "macd_periods": [12, 26, 9]
  }
}
```

## Integration with Trading Bot

### MEXC Trading Bot Integration
If you have the MEXC trading bot from earlier:
```python
# The analytics skill can monitor bot performance
TRADING_BOT_API = "http://localhost:8000"  # Your bot API

# Get stats like:
# - Total trades
# - Win rate
# - Profit factor
# - Active positions
```

### Custom Alerts Based on Bot Performance
- Alert when win rate drops below threshold
- Alert when profit factor changes significantly
- Alert when new positions are opened

## Report Examples

### Hourly Report
```
📊 TRADING ANALYTICS REPORT

Time: 2026-03-27 14:30:00
Price Alerts: 3

Portfolio Stats:
  Win Rate: 68%
  Profit Factor: 1.72
  Active Positions: 5

Recommendations:
  • BTC: Consider selling (Williams %R: -82.1)
  • ETH: RSI oversold (28.5)
  • SOL: Price breakout detected (+6.3%)
```

### Daily Summary Report
```
📈 DAILY SUMMARY

Symbols Monitored: 8
Total Alerts: 15
Average Win Rate: 70.2%
Best Performing: SOL (+8.5%)
Worst Performing: DOGE (-3.2%)

Market Trend: Bullish (4/8 symbols)
```

## Safety Rules

- Never share API keys or sensitive data
- Verify price data from multiple sources
- Use Williams %R with other indicators for confirmation
- Set reasonable alert thresholds to avoid noise
- Monitor API usage to avoid rate limits

## Troubleshooting

### Common Issues

1. **API Rate Limits**: Use multiple data sources or increase intervals
2. **Missing Price Data**: Check symbol format and API availability
3. **Indicator Calculation Errors**: Ensure enough historical data
4. **Telegram Notifications**: Verify bot token and chat ID

### Logs
```bash
# Check skill logs
tail -f trading_analytics.log

# Debug mode
python3 trading_analytics.py --debug
```

## Deployment

### VPS Deployment
```bash
# Use systemd service
sudo cp trading-analytics.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable trading-analytics
sudo systemctl start trading-analytics
```

### Docker Deployment
```bash
# Build Docker image
docker build -t trading-analytics .

# Run with config
docker run -v ./config.json:/app/config.json trading-analytics
```

## License

MIT - Free to use and modify

## Version

v1.0.0 - Initial release
2026-03-27