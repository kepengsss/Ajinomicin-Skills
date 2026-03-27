#!/bin/bash
# Install Single OpenClaw Skill

set -e  # Exit on error

echo "🔧 Install Single OpenClaw Skill"
echo "================================"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Log functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Configuration
OPENCLAW_SKILLS_DIR="${HOME}/.openclaw/skills"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Available skills
AVAILABLE_SKILLS=(
    "whale-tracker-private"
    "whale-tracker-solana" 
    "solana-pay"
    "polyhub_discover"
    "polyhub_copy"
    "polyhub_account"
)

# Show available skills
show_skills() {
    echo ""
    echo "📚 Available Skills:"
    echo "==================="
    echo ""
    echo "🔐 Private Skills:"
    echo "  whale-tracker-private  - Private whale tracking (Ajinomicin only)"
    echo ""
    echo "🌐 Public Skills:"
    echo "  whale-tracker-solana   - Public whale tracking"
    echo "  solana-pay             - Solana wallet manager"
    echo ""
    echo "🦞 PolyHub Skills:"
    echo "  polyhub_discover       - Trader discovery (no API key)"
    echo "  polyhub_copy           - Copy trading (needs API key)"
    echo "  polyhub_account        - Portfolio management (needs API key)"
    echo ""
}

# Install skill function
install_skill() {
    local skill_name="$1"
    local source_dir=""
    
    log_info "Installing skill: $skill_name"
    
    # Determine source directory
    case "$skill_name" in
        "whale-tracker-private")
            source_dir="$SCRIPT_DIR/whale-tracker-private"
            ;;
        "whale-tracker-solana")
            source_dir="$SCRIPT_DIR/whale-tracker-solana"
            ;;
        "solana-pay")
            source_dir="$SCRIPT_DIR/solana-pay"
            ;;
        "polyhub_discover"|"polyhub_copy"|"polyhub_account")
            source_dir="$SCRIPT_DIR/polyhub-skills/openclaw/$skill_name"
            ;;
        *)
            log_error "Unknown skill: $skill_name"
            show_skills
            exit 1
            ;;
    esac
    
    # Check if skill directory exists
    if [ ! -d "$source_dir" ]; then
        log_error "Skill directory not found: $source_dir"
        log_info "Make sure you have cloned the full repository"
        exit 1
    fi
    
    # Create target directory
    mkdir -p "$OPENCLAW_SKILLS_DIR/$skill_name"
    
    # Copy skill files
    log_info "Copying skill files..."
    cp -r "$source_dir"/* "$OPENCLAW_SKILLS_DIR/$skill_name/" 2>/dev/null || true
    
    # Install Python dependencies
    if [ -f "$source_dir/requirements.txt" ]; then
        log_info "Installing Python dependencies..."
        
        # Create virtual environment
        if [ ! -d "$OPENCLAW_SKILLS_DIR/$skill_name/venv" ]; then
            python3 -m venv "$OPENCLAW_SKILLS_DIR/$skill_name/venv"
        fi
        
        # Install packages
        source "$OPENCLAW_SKILLS_DIR/$skill_name/venv/bin/activate"
        pip install --upgrade pip
        pip install -r "$source_dir/requirements.txt"
        deactivate
        
        log_success "Python dependencies installed"
    fi
    
    # Install Node.js dependencies
    if [ -f "$source_dir/package.json" ]; then
        log_info "Installing Node.js dependencies..."
        
        cd "$OPENCLAW_SKILLS_DIR/$skill_name"
        npm install --quiet
        
        log_success "Node.js dependencies installed"
    fi
    
    # Check if SKILL.md exists
    if [ -f "$OPENCLAW_SKILLS_DIR/$skill_name/SKILL.md" ]; then
        log_success "Skill installed: $skill_name"
        
        # Show skill info
        echo ""
        echo "📋 Skill Information:"
        echo "-------------------"
        head -20 "$OPENCLAW_SKILLS_DIR/$skill_name/SKILL.md" | grep -E "name:|description:|emoji:" || true
    else
        log_warning "No SKILL.md found (may be a directory skill)"
    fi
    
    # Show configuration instructions
    show_config_instructions "$skill_name"
}

# Show configuration instructions
show_config_instructions() {
    local skill_name="$1"
    
    echo ""
    echo "⚙️ Configuration Instructions:"
    echo "---------------------------"
    
    case "$skill_name" in
        "whale-tracker-private")
            echo "1. Edit Telegram ID in whale_tracker_auth.py (line ~10)"
            echo "   AUTHORIZED_TELEGRAM_ID = \"1473275947\"  # Change to your ID"
            echo ""
            echo "2. Set Telegram bot token:"
            echo "   export TELEGRAM_BOT_TOKEN=\"your_bot_token\""
            echo ""
            echo "3. Run: python3 whale_tracker_auth.py"
            ;;
        "whale-tracker-solana")
            echo "1. Copy config template:"
            echo "   cp config.example.json config.json"
            echo ""
            echo "2. Edit config.json with your settings"
            echo "   - Telegram bot token & chat ID"
            echo "   - Whale wallet address"
            echo ""
            echo "3. Run: python3 whale_tracker.py"
            ;;
        "solana-pay")
            echo "1. Copy config template:"
            echo "   cp config.example.json config.json"
            echo ""
            echo "2. Edit config.json with:"
            echo "   - Solana private key (Base58)"
            echo "   - Avici address"
            echo "   - API keys (Helius, Jupiter, Moonshot)"
            echo ""
            echo "3. Install dependencies:"
            echo "   npm install"
            echo ""
            echo "4. Run: node index.js balance"
            ;;
        "polyhub_discover")
            echo "✅ Ready to use! No API key needed."
            echo ""
            echo "Usage: Access via OpenClaw skill system"
            ;;
        "polyhub_copy"|"polyhub_account")
            echo "1. Get PolyHub API key:"
            echo "   https://polyhub.hubble.xyz/"
            echo ""
            echo "2. Set environment variables:"
            echo "   export POLYHUB_API_BASE_URL=\"https://polyhub.skill-test.bedev.hubble-rpc.xyz\""
            echo "   export POLYHUB_API_KEY=\"phub_...\""
            echo ""
            echo "3. Restart OpenClaw"
            ;;
    esac
    
    echo ""
    echo "📁 Skill location: $OPENCLAW_SKILLS_DIR/$skill_name"
}

# Main function
main() {
    # Check if skill name provided
    if [ $# -eq 0 ]; then
        echo "❌ Usage: $0 <skill-name>"
        echo ""
        show_skills
        exit 1
    fi
    
    SKILL_NAME="$1"
    
    # Check if OpenClaw is installed
    if ! command -v openclaw &> /dev/null; then
        log_error "OpenClaw not found. Please install OpenClaw first."
        log_info "Installation guide: https://docs.openclaw.ai"
        exit 1
    fi
    
    # Create skills directory
    mkdir -p "$OPENCLAW_SKILLS_DIR"
    
    # Install the skill
    install_skill "$SKILL_NAME"
    
    # Final instructions
    echo ""
    echo "✅ Installation Complete!"
    echo "========================"
    echo ""
    echo "🎯 Next Steps:"
    echo "  1. Configure the skill as shown above"
    echo "  2. Restart OpenClaw if needed: openclaw restart"
    echo "  3. Test the skill via OpenClaw interface"
    echo ""
    echo "🔧 Manage all skills: ./install_all.sh"
    echo "🔄 Update skills: ./update_all.sh"
}

# Run main
main "$@"