#!/bin/bash
# Deployment Script for Whale Tracker

set -e  # Exit on error

echo "🚀 DEPLOYING WHALE TRACKER TO VPS 🚀"
echo "===================================="

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Log functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Configuration
DEPLOY_DIR="/opt/whale-tracker"
SERVICE_NAME="whale-tracker"
USER_NAME="whaleuser"

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    log_error "Please run as root or with sudo"
    exit 1
fi

# Step 1: System Update & Dependencies
log_info "Updating system packages..."
apt-get update -y
apt-get upgrade -y

log_info "Installing system dependencies..."
apt-get install -y \
    python3 \
    python3-pip \
    python3-venv \
    git \
    curl \
    wget \
    tmux \
    screen \
    htop \
    nginx \
    ufw \
    fail2ban

# Step 2: Create dedicated user
log_info "Creating dedicated user..."
if id "$USER_NAME" &>/dev/null; then
    log_warning "User $USER_NAME already exists"
else
    useradd -m -s /bin/bash "$USER_NAME"
    usermod -aG sudo "$USER_NAME"
    log_success "User $USER_NAME created"
fi

# Step 3: Create deployment directory
log_info "Creating deployment directory..."
mkdir -p "$DEPLOY_DIR"
chown -R "$USER_NAME:$USER_NAME" "$DEPLOY_DIR"

# Step 4: Copy project files
log_info "Copying project files..."
cp -r /root/.openclaw/workspace/whale_tracker.py "$DEPLOY_DIR/"
cp -r /root/.openclaw/workspace/config_whale.json "$DEPLOY_DIR/"
cp -r /root/.openclaw/workspace/start_tracker.sh "$DEPLOY_DIR/"
cp -r /root/.openclaw/workspace/README_whale_tracker.md "$DEPLOY_DIR/"

# Make scripts executable
chmod +x "$DEPLOY_DIR/start_tracker.sh"
chmod +x "$DEPLOY_DIR/deploy_whale_tracker.sh"

# Step 5: Setup Python environment
log_info "Setting up Python environment..."
sudo -u "$USER_NAME" bash << EOF
cd "$DEPLOY_DIR"
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install aiohttp solders solana websockets requests
EOF

# Step 6: Create environment configuration
log_info "Creating environment configuration..."
cat > "$DEPLOY_DIR/.env" << 'EOF'
# Whale Tracker Configuration
# ===========================

# Telegram Configuration (REQUIRED)
# Get bot token from @BotFather
TELEGRAM_BOT_TOKEN=your_bot_token_here

# Get chat ID by sending message to bot, then check:
# curl https://api.telegram.org/bot<TOKEN>/getUpdates
TELEGRAM_CHAT_ID=your_chat_id_here

# RPC Configuration (Optional - override defaults)
# SOLANA_RPC=https://api.mainnet-beta.solana.com
# SOLANA_WS=wss://api.mainnet-beta.solana.com

# Monitoring Configuration (Optional)
# CHECK_INTERVAL=10
# MIN_SOL_FOR_ROTATION=10.0
EOF

log_warning "Please edit $DEPLOY_DIR/.env with your Telegram credentials!"

# Step 7: Create systemd service
log_info "Creating systemd service..."
cat > "/etc/systemd/system/$SERVICE_NAME.service" << EOF
[Unit]
Description=Solana Whale Tracker
After=network.target
StartLimitIntervalSec=0

[Service]
Type=simple
User=$USER_NAME
WorkingDirectory=$DEPLOY_DIR
Environment=PATH=$DEPLOY_DIR/venv/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
EnvironmentFile=$DEPLOY_DIR/.env
ExecStart=$DEPLOY_DIR/venv/bin/python3 $DEPLOY_DIR/whale_tracker.py
Restart=always
RestartSec=10
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=$SERVICE_NAME

# Security
NoNewPrivileges=true
ProtectSystem=strict
PrivateTmp=true
PrivateDevices=true
ProtectHome=true
ProtectKernelTunables=true
ProtectKernelModules=true
ProtectControlGroups=true

[Install]
WantedBy=multi-user.target
EOF

# Step 8: Create monitoring script
log_info "Creating monitoring and management scripts..."

# Monitor script
cat > "$DEPLOY_DIR/monitor.sh" << 'EOF'
#!/bin/bash
echo "🔍 Whale Tracker Status"
echo "======================"
sudo systemctl status whale-tracker --no-pager
echo ""
echo "📊 Recent Logs:"
sudo journalctl -u whale-tracker -n 20 --no-pager
EOF

# Restart script
cat > "$DEPLOY_DIR/restart.sh" << 'EOF'
#!/bin/bash
echo "🔄 Restarting Whale Tracker..."
sudo systemctl restart whale-tracker
sleep 3
sudo systemctl status whale-tracker --no-pager
EOF

# Logs script
cat > "$DEPLOY_DIR/logs.sh" << 'EOF'
#!/bin/bash
echo "📋 Whale Tracker Logs"
echo "===================="
sudo journalctl -u whale-tracker -f
EOF

chmod +x "$DEPLOY_DIR/monitor.sh"
chmod +x "$DEPLOY_DIR/restart.sh"
chmod +x "$DEPLOY_DIR/logs.sh"

# Step 9: Setup firewall
log_info "Configuring firewall..."
ufw --force enable
ufw allow OpenSSH
ufw allow 'Nginx Full'
log_success "Firewall configured"

# Step 10: Enable and start service
log_info "Reloading systemd..."
systemctl daemon-reload

log_info "Enabling service..."
systemctl enable "$SERVICE_NAME"

log_info "Starting Whale Tracker service..."
systemctl start "$SERVICE_NAME"

sleep 3

# Step 11: Check service status
log_info "Checking service status..."
if systemctl is-active --quiet "$SERVICE_NAME"; then
    log_success "Whale Tracker service is running!"
    echo ""
    echo "✅ DEPLOYMENT COMPLETE ✅"
    echo "========================="
    echo ""
    echo "📁 Installation Directory: $DEPLOY_DIR"
    echo "👤 Service User: $USER_NAME"
    echo "🔧 Service Name: $SERVICE_NAME"
    echo ""
    echo "🎯 NEXT STEPS:"
    echo "1. Edit Telegram credentials:"
    echo "   nano $DEPLOY_DIR/.env"
    echo ""
    echo "2. Configure wallet to track:"
    echo "   Edit first line in whale_tracker.py or"
    echo "   Run manually to input wallet"
    echo ""
    echo "3. Management Commands:"
    echo "   - Check status: $DEPLOY_DIR/monitor.sh"
    echo "   - View logs: $DEPLOY_DIR/logs.sh"
    echo "   - Restart: $DEPLOY_DIR/restart.sh"
    echo "   - Stop: sudo systemctl stop whale-tracker"
    echo "   - Start: sudo systemctl start whale-tracker"
    echo ""
    echo "4. To manually run and input whale wallet:"
    echo "   cd $DEPLOY_DIR"
    echo "   source venv/bin/activate"
    echo "   python3 whale_tracker.py"
    echo ""
else
    log_error "Service failed to start!"
    echo "Checking logs..."
    journalctl -u "$SERVICE_NAME" -n 20 --no-pager
    exit 1
fi

# Step 12: Create quick access aliases
cat >> /home/$USER_NAME/.bashrc << 'EOF'
# Whale Tracker Aliases
alias whale-status='sudo systemctl status whale-tracker'
alias whale-logs='sudo journalctl -u whale-tracker -f'
alias whale-restart='sudo systemctl restart whale-tracker'
alias whale-stop='sudo systemctl stop whale-tracker'
alias whale-start='sudo systemctl start whale-tracker'
EOF

log_success "Aliases added to $USER_NAME's .bashrc"

echo ""
echo "🎉 DEPLOYMENT FINISHED!"
echo "Whale Tracker is now running on your VPS 24/7"
echo "Make sure to configure .env file and input whale wallet!"