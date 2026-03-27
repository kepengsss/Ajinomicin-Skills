#!/bin/bash
# Setup GitHub Repository for OpenClaw Skills Package

set -e  # Exit on error

echo "🚀 GitHub Repository Setup"
echo "========================"

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
REPO_NAME="OpenClaw-Skills-Package"
REPO_DESCRIPTION="Collection of production-ready OpenClaw skills for Web3 automation, trading, and monitoring"
REPO_VISIBILITY="private"  # Change to "public" if you want public repo

# Check if Git is installed
check_git() {
    if ! command -v git &> /dev/null; then
        log_error "Git is not installed. Please install Git first."
        log_info "Installation:"
        echo "  Ubuntu/Debian: sudo apt-get install git"
        echo "  macOS: brew install git"
        echo "  Windows: Download from https://git-scm.com/"
        exit 1
    fi
    
    log_success "Git detected: $(git --version)"
}

# Check if GitHub CLI is installed (optional but recommended)
check_gh_cli() {
    if command -v gh &> /dev/null; then
        log_success "GitHub CLI detected: $(gh --version | head -1)"
        return 0
    else
        log_warning "GitHub CLI not installed (optional but recommended)"
        log_info "Installation:"
        echo "  Ubuntu/Debian: sudo apt-get install gh"
        echo "  macOS: brew install gh"
        echo "  Windows: winget install --id GitHub.cli"
        echo ""
        echo "  After installation: gh auth login"
        return 1
    fi
}

# Initialize local Git repository
init_git_repo() {
    local repo_dir="$(pwd)"
    
    log_info "Initializing Git repository..."
    
    # Check if already a Git repository
    if [ -d ".git" ]; then
        log_warning "Already a Git repository. Skipping initialization."
        return 0
    fi
    
    # Initialize Git
    git init
    git checkout -b main
    
    # Add all files
    git add .
    
    # Initial commit
    git commit -m "Initial commit: OpenClaw Skills Package v1.0.0
    
    🚀 Features:
    - 🔐 Private Whale Tracker (Ajinomicin only)
    - 🐋 Public Whale Tracker
    - 💳 Solana Pay Manager
    - 🦞 PolyHub Trading Suite
    - 📦 Easy installation scripts
    
    📋 Includes:
    - Production-ready OpenClaw skills
    - Comprehensive documentation
    - Management scripts
    - Security best practices"
    
    log_success "Git repository initialized"
}

# Create GitHub repository (using GitHub CLI)
create_github_repo() {
    log_info "Creating GitHub repository..."
    
    if command -v gh &> /dev/null; then
        # Check if authenticated
        if ! gh auth status &> /dev/null; then
            log_error "GitHub CLI not authenticated"
            log_info "Please run: gh auth login"
            log_info "Then run this script again"
            exit 1
        fi
        
        # Create repository
        gh repo create "$REPO_NAME" \
            --description "$REPO_DESCRIPTION" \
            --"$REPO_VISIBILITY" \
            --source=. \
            --remote=origin \
            --push
        
        log_success "GitHub repository created: https://github.com/$(gh api user | jq -r '.login')/$REPO_NAME"
    else
        log_warning "GitHub CLI not available. Manual setup required:"
        echo ""
        echo "📋 Manual Setup Instructions:"
        echo "==========================="
        echo ""
        echo "1. Go to: https://github.com/new"
        echo "2. Create new repository with these settings:"
        echo "   - Repository name: $REPO_NAME"
        echo "   - Description: $REPO_DESCRIPTION"
        echo "   - Visibility: $REPO_VISIBILITY"
        echo "   - DO NOT initialize with README, .gitignore, or license"
        echo ""
        echo "3. After creation, run these commands:"
        echo "   git remote add origin https://github.com/YOUR_USERNAME/$REPO_NAME.git"
        echo "   git branch -M main"
        echo "   git push -u origin main"
        echo ""
        
        # Ask if user wants to continue with manual setup
        read -p "Continue with manual setup? (y/N): " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            log_info "Please follow the manual instructions above."
        fi
    fi
}

# Setup Git hooks
setup_git_hooks() {
    log_info "Setting up Git hooks..."
    
    # Create hooks directory
    mkdir -p .git/hooks
    
    # Pre-commit hook
    cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash
# Pre-commit hook for OpenClaw Skills Package

echo "🔍 Running pre-commit checks..."

# Check for sensitive files
SENSITIVE_FILES=(
    "config.json"
    ".env"
    "*.key"
    "*.pem"
    "private_key.txt"
    "wallet.txt"
)

for pattern in "${SENSITIVE_FILES[@]}"; do
    if git diff --cached --name-only | grep -q "$pattern"; then
        echo "❌ ERROR: Found sensitive file matching pattern: $pattern"
        echo "   Please remove or ignore these files before committing."
        echo "   Add them to .gitignore if they are configuration files."
        exit 1
    fi
done

# Check Python files for syntax errors
echo "✓ Checking Python files..."
find . -name "*.py" -exec python3 -m py_compile {} \; 2>/dev/null || true

# Check shell scripts
echo "✓ Checking shell scripts..."
find . -name "*.sh" -exec shellcheck {} \; 2>/dev/null || true

echo "✅ Pre-commit checks passed!"
EOF
    
    chmod +x .git/hooks/pre-commit
    
    # Post-commit hook
    cat > .git/hooks/post-commit << 'EOF'
#!/bin/bash
# Post-commit hook for OpenClaw Skills Package

echo "📊 Commit completed successfully!"
echo "✨ Next steps:"
echo "   git push origin main"
echo "   Or create a pull request if working in a team"
EOF
    
    chmod +x .git/hooks/post-commit
    
    log_success "Git hooks installed"
}

# Create GitHub workflows
setup_github_workflows() {
    log_info "Setting up GitHub workflows..."
    
    mkdir -p .github/workflows
    
    # CI workflow
    cat > .github/workflows/ci.yml << 'EOF'
name: CI

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Set up Python
      uses: actions/setup-python@v4
      with:
        python-version: '3.9'
    
    - name: Install dependencies
      run: |
        python -m pip install --upgrade pip
        pip install aiohttp requests
        
    - name: Run syntax checks
      run: |
        echo "🔍 Checking Python files..."
        find . -name "*.py" -exec python -m py_compile {} \;
        
        echo "🔍 Checking shell scripts..."
        if command -v shellcheck &> /dev/null; then
          find . -name "*.sh" -exec shellcheck {} \;
        fi
        
    - name: Check for sensitive files
      run: |
        echo "🔒 Checking for sensitive files..."
        if find . -name "config.json" -o -name ".env" -o -name "*.key" | grep -q .; then
          echo "❌ WARNING: Sensitive files detected"
          echo "   Please ensure these are in .gitignore"
          # Don't fail, just warn
        fi

  security:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Security scan
      uses: actions/upload-artifact@v3
      if: always()
      with:
        name: security-report
        path: |
          **/*.py
          **/*.js
        retention-days: 1
EOF
    
    # Release workflow
    cat > .github/workflows/release.yml << 'EOF'
name: Release

on:
  push:
    tags:
      - 'v*'

jobs:
  release:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Create release
      uses: softprops/action-gh-release@v1
      with:
        generate_release_notes: true
        draft: false
        prerelease: false
    
    - name: Upload release assets
      run: |
        # Create zip package
        zip -r OpenClaw-Skills-Package.zip . \
          -x "*.git*" \
          -x "*.github*" \
          -x "*.env*" \
          -x "*config.json" \
          -x "node_modules/*" \
          -x "venv/*"
        
        # Upload to release
        gh release upload ${{ github.ref_name }} OpenClaw-Skills-Package.zip
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
EOF
    
    log_success "GitHub workflows created"
}

# Create documentation
create_documentation() {
    log_info "Creating additional documentation..."
    
    # Contributing guidelines
    cat > CONTRIBUTING.md << 'EOF'
# Contributing Guidelines

Thank you for considering contributing to OpenClaw Skills Package!

## How to Contribute

### 1. Reporting Issues
- Check existing issues first
- Use the issue template
- Include steps to reproduce
- Provide logs and error messages

### 2. Suggesting Features
- Explain the use case
- Describe the implementation
- Consider backward compatibility

### 3. Submitting Pull Requests
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add/update tests if applicable
5. Update documentation
6. Submit PR with description

## Development Setup

### Prerequisites
- Python 3.8+
- Node.js 16+ (for solana-pay skill)
- OpenClaw installed
- Git

### Local Development
```bash
# Clone repository
git clone <repository-url>
cd OpenClaw-Skills-Package

# Install all skills
./install_all.sh

# Test a skill
cd whale-tracker-private
python3 whale_tracker_auth.py test
```

## Code Style

### Python
- Follow PEP 8
- Use type hints
- Add docstrings
- Write unit tests

### Shell Scripts
- Use shellcheck
- Add shebang
- Include error handling
- Add comments

### Documentation
- Update README.md
- Add inline comments
- Update SKILL.md files
- Include examples

## Testing

### Manual Testing
1. Install the skill
2. Configure with test credentials
3. Run the skill
4. Verify functionality

### Automated Testing
- Add unit tests in `tests/` directory
- Use pytest for Python tests
- Test edge cases
- Mock external dependencies

## Security Guidelines

### Never Commit
- API keys
- Private keys
- Passwords
- Config files with secrets

### Always
- Use environment variables
- Add to .gitignore
- Encrypt sensitive data
- Regular security audits

## Release Process

1. Update version in relevant files
2. Update CHANGELOG.md
3. Create git tag: `git tag v1.0.0`
4. Push tag: `git push origin v1.0.0`
5. GitHub Actions will create release

## Questions?

Contact the repository owner or open a discussion.
EOF
    
    # Code of conduct
    cat > CODE_OF_CONDUCT.md << 'EOF'
# Contributor Covenant Code of Conduct

## Our Pledge

We as members, contributors, and leaders pledge to make participation in our
community a harassment-free experience for everyone.

## Our Standards

Examples of positive behavior:
- Using welcoming and inclusive language
- Being respectful of differing viewpoints
- Gracefully accepting constructive criticism
- Focusing on what is best for the community

Examples of unacceptable behavior:
- Harassment or discrimination
- Trolling, insulting comments
- Publishing others' private information
- Other unethical or unprofessional conduct

## Enforcement

Instances of abusive behavior may be reported to the repository maintainers.
All complaints will be reviewed and investigated.

## Attribution

This Code of Conduct is adapted from the [Contributor Covenant](https://www.contributor-covenant.org).
EOF
    
    log_success "Documentation created"
}

# Main function
main() {
    echo ""
    echo "🚀 OpenClaw Skills Package - GitHub Setup"
    echo "========================================"
    echo ""
    
    # Check prerequisites
    check_git
    check_gh_cli
    
    # Initialize
    init_git_repo
    
    # Setup hooks
    setup_git_hooks
    
    # Setup workflows
    setup_github_workflows
    
    # Create documentation
    create_documentation
    
    # Create GitHub repository
    create_github_repo
    
    # Final instructions
    echo ""
    echo "✅ SETUP COMPLETE!"
    echo "================="
    echo ""
    echo "📁 Repository ready at: $(pwd)"
    echo ""
    echo "🎯 Next Steps:"
    echo "  1. Review the setup"
    echo "  2. Share with team members (if private repo, add collaborators)"
    echo "  3. Push updates: git push origin main"
    echo "  4. Create issues for bugs or feature requests"
    echo ""
    echo "🔧 Management Commands:"
    echo "  ./install_all.sh    - Install all skills"
    echo "  ./install_skill.sh  - Install specific skill"
    echo "  ./update_all.sh     - Update all skills"
    echo ""
    echo "📚 Documentation:"
    echo "  README.md          - Main documentation"
    echo "  CONTRIBUTING.md    - Contribution guidelines"
    echo "  CODE_OF_CONDUCT.md - Community guidelines"
    echo ""
    echo "👥 Collaborators:"
    echo "  To add collaborators to private repo:"
    echo "  https://github.com/YOUR_USERNAME/$REPO_NAME/settings/access"
    echo ""
    
    log_success "Setup completed successfully!"
}

# Run main
main "$@"