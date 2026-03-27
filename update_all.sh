#!/bin/bash
# Update All OpenClaw Skills

set -e  # Exit on error

echo "🔄 Updating OpenClaw Skills Package"
echo "=================================="

# Colors
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

# Configuration
OPENCLAW_SKILLS_DIR="${HOME}/.openclaw/skills"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="${HOME}/.openclaw/skills_backup_update_$(date +%Y%m%d_%H%M%S)"

# Backup config files before update
backup_configs() {
    log_info "Backing up configuration files..."
    
    mkdir -p "$BACKUP_DIR"
    
    # Backup each skill's config files
    for skill_dir in "$OPENCLAW_SKILLS_DIR"/*; do
        if [ -d "$skill_dir" ]; then
            skill_name="$(basename "$skill_dir")"
            
            # Backup config.json if exists
            if [ -f "$skill_dir/config.json" ]; then
                mkdir -p "$BACKUP_DIR/$skill_name"
                cp "$skill_dir/config.json" "$BACKUP_DIR/$skill_name/config.json.backup"
                log_info "  Backed up $skill_name/config.json"
            fi
            
            # Backup .env if exists
            if [ -f "$skill_dir/.env" ]; then
                mkdir -p "$BACKUP_DIR/$skill_name"
                cp "$skill_dir/.env" "$BACKUP_DIR/$skill_name/.env.backup"
                log_info "  Backed up $skill_name/.env"
            fi
        fi
    done
    
    log_success "Backup created: $BACKUP_DIR"
}

# Update skill function
update_skill() {
    local skill_name="$1"
    local source_dir=""
    
    log_info "Updating skill: $skill_name"
    
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
            log_warning "Unknown or external skill: $skill_name (skipping)"
            return 0
            ;;
    esac
    
    # Check if source directory exists
    if [ ! -d "$source_dir" ]; then
        log_warning "Source directory not found: $source_dir"
        log_warning "Skill $skill_name may be external or removed from package"
        return 0
    fi
    
    # Check if skill is installed
    if [ ! -d "$OPENCLAW_SKILLS_DIR/$skill_name" ]; then
        log_warning "Skill not installed: $skill_name (run install_skill.sh first)"
        return 0
    fi
    
    # Backup current config files
    if [ -f "$OPENCLAW_SKILLS_DIR/$skill_name/config.json" ]; then
        cp "$OPENCLAW_SKILLS_DIR/$skill_name/config.json" \
           "$OPENCLAW_SKILLS_DIR/$skill_name/config.json.backup"
    fi
    
    if [ -f "$OPENCLAW_SKILLS_DIR/$skill_name/.env" ]; then
        cp "$OPENCLAW_SKILLS_DIR/$skill_name/.env" \
           "$OPENCLAW_SKILLS_DIR/$skill_name/.env.backup"
    fi
    
    # Remove old files (except configs and venv)
    log_info "Removing old files..."
    find "$OPENCLAW_SKILLS_DIR/$skill_name" -maxdepth 1 \
         -not -name "config.json" \
         -not -name ".env" \
         -not -name "venv" \
         -not -name "node_modules" \
         -not -name "*.backup" \
         -not -name "." \
         -exec rm -rf {} + 2>/dev/null || true
    
    # Copy new files
    log_info "Copying updated files..."
    cp -r "$source_dir"/* "$OPENCLAW_SKILLS_DIR/$skill_name/" 2>/dev/null || true
    
    # Restore config files
    if [ -f "$OPENCLAW_SKILLS_DIR/$skill_name/config.json.backup" ]; then
        mv "$OPENCLAW_SKILLS_DIR/$skill_name/config.json.backup" \
           "$OPENCLAW_SKILLS_DIR/$skill_name/config.json"
        log_info "  Restored config.json"
    fi
    
    if [ -f "$OPENCLAW_SKILLS_DIR/$skill_name/.env.backup" ]; then
        mv "$OPENCLAW_SKILLS_DIR/$skill_name/.env.backup" \
           "$OPENCLAW_SKILLS_DIR/$skill_name/.env"
        log_info "  Restored .env"
    fi
    
    # Update dependencies
    update_dependencies "$skill_name" "$source_dir"
    
    log_success "Updated: $skill_name"
}

# Update dependencies
update_dependencies() {
    local skill_name="$1"
    local source_dir="$2"
    
    # Update Python dependencies
    if [ -f "$source_dir/requirements.txt" ]; then
        log_info "Updating Python dependencies..."
        
        # Check if venv exists
        if [ ! -d "$OPENCLAW_SKILLS_DIR/$skill_name/venv" ]; then
            python3 -m venv "$OPENCLAW_SKILLS_DIR/$skill_name/venv"
        fi
        
        # Update packages
        source "$OPENCLAW_SKILLS_DIR/$skill_name/venv/bin/activate"
        pip install --upgrade pip
        pip install -r "$source_dir/requirements.txt" --upgrade
        deactivate
        
        log_success "Python dependencies updated"
    fi
    
    # Update Node.js dependencies
    if [ -f "$source_dir/package.json" ]; then
        log_info "Updating Node.js dependencies..."
        
        cd "$OPENCLAW_SKILLS_DIR/$skill_name"
        npm update --quiet
        
        log_success "Node.js dependencies updated"
    fi
}

# Check for updates from Git (if repository is git-based)
check_git_updates() {
    if [ -d "$SCRIPT_DIR/.git" ]; then
        log_info "Checking for Git updates..."
        
        cd "$SCRIPT_DIR"
        git fetch origin
        
        LOCAL_COMMIT=$(git rev-parse HEAD)
        REMOTE_COMMIT=$(git rev-parse origin/main 2>/dev/null || git rev-parse origin/master 2>/dev/null)
        
        if [ "$LOCAL_COMMIT" != "$REMOTE_COMMIT" ]; then
            log_warning "New updates available in Git repository"
            echo "  Local:  $LOCAL_COMMIT"
            echo "  Remote: $REMOTE_COMMIT"
            echo ""
            echo "To update the repository:"
            echo "  cd $SCRIPT_DIR"
            echo "  git pull origin main"
            echo ""
            read -p "Update repository now? (y/N): " -n 1 -r
            echo ""
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                git pull origin main
                log_success "Repository updated"
            fi
        else
            log_success "Repository is up to date"
        fi
    else
        log_warning "Not a Git repository - manual updates only"
    fi
}

# Show update summary
show_summary() {
    echo ""
    echo "📊 Update Summary"
    echo "================"
    echo ""
    
    # List updated skills
    echo "✅ Updated Skills:"
    for skill in whale-tracker-private whale-tracker-solana solana-pay \
                 polyhub_discover polyhub_copy polyhub_account; do
        if [ -d "$OPENCLAW_SKILLS_DIR/$skill" ]; then
            echo "  - $skill"
        fi
    done
    echo ""
    
    # List external skills (not in package)
    echo "📦 External Skills (not updated):"
    for skill_dir in "$OPENCLAW_SKILLS_DIR"/*; do
        if [ -d "$skill_dir" ]; then
            skill_name="$(basename "$skill_dir")"
            case "$skill_name" in
                "whale-tracker-private"|"whale-tracker-solana"|"solana-pay"| \
                "polyhub_discover"|"polyhub_copy"|"polyhub_account")
                    # These are package skills, already listed
                    ;;
                *)
                    echo "  - $skill_name (external/custom)"
                    ;;
            esac
        fi
    done
    echo ""
    
    # Backup info
    if [ -d "$BACKUP_DIR" ]; then
        echo "💾 Configuration backups: $BACKUP_DIR"
        echo "   To restore: cp $BACKUP_DIR/*/config.json.backup $OPENCLAW_SKILLS_DIR/*/config.json"
        echo ""
    fi
    
    # Next steps
    echo "🚀 Next Steps:"
    echo "  1. Test updated skills"
    echo "  2. Restart OpenClaw if needed: openclaw restart"
    echo "  3. Check for breaking changes in skill documentation"
    echo ""
}

# Main function
main() {
    echo ""
    echo "🔄 OpenClaw Skills Updater"
    echo "========================="
    echo ""
    
    # Check if OpenClaw is installed
    if ! command -v openclaw &> /dev/null; then
        log_warning "OpenClaw not found. Skills directory: $OPENCLAW_SKILLS_DIR"
    fi
    
    # Create skills directory if needed
    mkdir -p "$OPENCLAW_SKILLS_DIR"
    
    # Check Git updates
    check_git_updates
    
    # Backup configs
    backup_configs
    
    echo ""
    echo "📁 Updating skills..."
    echo "-------------------"
    
    # Update each skill
    update_skill "whale-tracker-private"
    update_skill "whale-tracker-solana"
    update_skill "solana-pay"
    update_skill "polyhub_discover"
    update_skill "polyhub_copy"
    update_skill "polyhub_account"
    
    # Show summary
    show_summary
    
    echo "✅ Update Complete!"
    echo "=================="
}

# Run main
main "$@"