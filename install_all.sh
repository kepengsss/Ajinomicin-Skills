#!/bin/bash
# Install All OpenClaw Skills Package

set -e  # Exit on error

echo "🚀 Installing OpenClaw Skills Package"
echo "===================================="

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

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Configuration
OPENCLAW_SKILLS_DIR="${HOME}/.openclaw/skills"
BACKUP_DIR="${HOME}/.openclaw/skills_backup_$(date +%Y%m%d_%H%M%S)"

# Create backup of existing skills
backup_existing_skills() {
    if [ -d "$OPENCLAW_SKILLS_DIR" ] && [ "$(ls -A $OPENCLAW_SKILLS_DIR 2>/dev/null)" ]; then
        log_info "Backing up existing skills..."
        mkdir -p "$BACKUP_DIR"
        cp -r "$OPENCLAW_SKILLS_DIR"/* "$BACKUP_DIR/" 2>/dev/null || true
        log_success "Backup created: $BACKUP_DIR"
    fi
}

# Check OpenClaw installation
check_openclaw() {
    if ! command -v openclaw &> /dev/null; then
        log_error "OpenClaw not found. Please install OpenClaw first."
        log_info "Installation guide: https://docs.openclaw.ai"
        exit 1
    fi
    
    log_success "OpenClaw detected: $(openclaw --version 2>/dev/null || echo 'unknown version')"
}

# Install skill function
install_skill() {
    local skill_name="$1"
    local skill_dir="$2"
    
    log_info "Installing $skill_name..."
    
    if [ ! -d "$skill_dir" ]; then
        log_error "Skill directory not found: $skill_dir"
        return 1
    fi
    
    # Create target directory
    mkdir -p "$OPENCLAW_SKILLS_DIR/$skill_name"
    
    # Copy skill files
    cp -r "$skill_dir"/* "$OPENCLAW_SKILLS_DIR/$skill_name/" 2>/dev/null || true
    
    # Check if SKILL.md exists
    if [ ! -f "$OPENCLAW_SKILLS_DIR/$skill_name/SKILL.md" ]; then
        log_warning "No SKILL.md found for $skill_name (may be a directory skill)"
    fi
    
    log_success "Installed $skill_name"
}

# Install Python dependencies for a skill
install_python_deps() {
    local skill_dir="$1"
    
    if [ -f "$skill_dir/requirements.txt" ]; then
        log_info "Installing Python dependencies..."
        
        # Check if virtual environment exists
        if [ ! -d "$skill_dir/venv" ]; then
            python3 -m venv "$skill_dir/venv"
        fi
        
        # Activate venv and install
        source "$skill_dir/venv/bin/activate"
        pip install --upgrade pip
        pip install -r "$skill_dir/requirements.txt"
        deactivate
        
        log_success "Python dependencies installed"
    fi
}

# Install Node.js dependencies for a skill
install_node_deps() {
    local skill_dir="$1"
    
    if [ -f "$skill_dir/package.json" ]; then
        log_info "Installing Node.js dependencies..."
        
        cd "$skill_dir"
        npm install --quiet
        
        log_success "Node.js dependencies installed"
    fi
}

# Main installation
main() {
    echo ""
    echo "📦 OpenClaw Skills Package Installer"
    echo "==================================="
    echo ""
    
    # Check requirements
    check_openclaw
    
    # Create skills directory
    mkdir -p "$OPENCLAW_SKILLS_DIR"
    
    # Backup existing skills
    backup_existing_skills
    
    # Get script directory
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    
    # Install each skill
    echo ""
    echo "📁 Installing Skills..."
    echo "----------------------"
    
    # 1. Private Whale Tracker
    if [ -d "$SCRIPT_DIR/whale-tracker-private" ]; then
        install_skill "whale-tracker-private" "$SCRIPT_DIR/whale-tracker-private"
        install_python_deps "$SCRIPT_DIR/whale-tracker-private"
    fi
    
    # 2. Public Whale Tracker
    if [ -d "$SCRIPT_DIR/whale-tracker-solana" ]; then
        install_skill "whale-tracker-solana" "$SCRIPT_DIR/whale-tracker-solana"
        install_python_deps "$SCRIPT_DIR/whale-tracker-solana"
    fi
    
    # 3. Solana Pay
    if [ -d "$SCRIPT_DIR/solana-pay" ]; then
        install_skill "solana-pay" "$SCRIPT_DIR/solana-pay"
        install_node_deps "$SCRIPT_DIR/solana-pay"
    fi
    
    # 4. PolyHub Skills
    if [ -d "$SCRIPT_DIR/polyhub-skills/openclaw" ]; then
        log_info "Installing PolyHub skills..."
        
        # Install each PolyHub skill
        for skill in "$SCRIPT_DIR/polyhub-skills/openclaw"/*; do
            if [ -d "$skill" ]; then
                skill_name="$(basename "$skill")"
                install_skill "$skill_name" "$skill"
            fi
        done
        
        log_success "PolyHub skills installed"
    fi
    
    # Summary
    echo ""
    echo "✅ INSTALLATION COMPLETE"
    echo "========================"
    echo ""
    echo "📁 Skills installed to: $OPENCLAW_SKILLS_DIR"
    echo ""
    echo "🎯 Installed Skills:"
    echo "  🔐 whale-tracker-private  - Private whale tracking"
    echo "  🐋 whale-tracker-solana   - Public whale tracking"
    echo "  💳 solana-pay             - Solana wallet manager"
    echo "  🦞 polyhub_discover       - PolyHub trader discovery"
    echo "  📋 polyhub_copy           - PolyHub copy trading"
    echo "  📊 polyhub_account        - PolyHub portfolio management"
    echo ""
    echo "🚀 Next Steps:"
    echo "  1. Configure each skill's config.json"
    echo "  2. Set up API keys in .env file"
    echo "  3. Restart OpenClaw: openclaw restart"
    echo "  4. Test skills with: openclaw skill list"
    echo ""
    echo "🔧 Management:"
    echo "  - Update skills: ./update_all.sh"
    echo "  - Install single: ./install_skill.sh <name>"
    echo "  - Start skill: ./start_skill.sh <name>"
    echo ""
    
    # Check if OpenClaw needs restart
    log_info "You may need to restart OpenClaw for changes to take effect:"
    echo "  openclaw restart"
    echo ""
    
    # Backup reminder
    if [ -d "$BACKUP_DIR" ]; then
        log_warning "Original skills backed up to: $BACKUP_DIR"
        echo "  To restore: cp -r $BACKUP_DIR/* $OPENCLAW_SKILLS_DIR/"
    fi
}

# Run main
main "$@"