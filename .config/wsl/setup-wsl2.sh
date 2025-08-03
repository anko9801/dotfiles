#!/usr/bin/env bash
# WSL2 setup script

set -euo pipefail

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

info() { echo -e "${GREEN}➜${NC} $1"; }
warn() { echo -e "${YELLOW}⚠${NC} $1"; }
error() { echo -e "${RED}✗${NC} $1" >&2; }

# Check if running on WSL2
if [[ ! $(uname -r) =~ microsoft ]]; then
    error "This script is for WSL2 only!"
    exit 1
fi

info "Setting up WSL2 environment..."

# Install essential packages for WSL2
info "Installing WSL2 essential packages..."
if command -v apt-get >/dev/null 2>&1; then
    sudo apt-get update
    sudo apt-get install -y \
        socat \
        ntpdate \
        wslu \
        xdg-utils
fi

# Setup 1Password SSH agent (Windows side)
setup_1password_windows() {
    info "Setting up 1Password SSH agent..."
    
    cat << 'EOF'

To use 1Password SSH agent in WSL2, you need to:

1. Install npiperelay on Windows:
   - Download from: https://github.com/jstarks/npiperelay/releases
   - Place npiperelay.exe in a Windows PATH directory (e.g., C:\Windows\System32)

2. Enable SSH agent in 1Password:
   - Open 1Password 8 settings
   - Go to Developer → SSH Agent
   - Enable "Use the SSH agent"

3. Test the setup:
   ssh-add -l

If you see your SSH keys, the setup is complete!

EOF
}

# Create WSL2 config symlink
info "Setting up WSL configuration..."
if [[ -f "$HOME/.config/wsl/wsl.conf" ]] && [[ ! -f "/etc/wsl.conf" ]]; then
    warn "WSL config found. To apply, run:"
    echo "  sudo cp $HOME/.config/wsl/wsl.conf /etc/wsl.conf"
    echo "  Then restart WSL2 with: wsl --shutdown (from Windows)"
fi

# Docker Desktop integration
if command -v docker >/dev/null 2>&1; then
    info "Docker Desktop integration detected"
else
    warn "Docker Desktop not detected. Install Docker Desktop for Windows for best experience."
fi

# Setup Windows Terminal integration
setup_windows_terminal() {
    info "Windows Terminal integration..."
    
    cat << 'EOF'

For the best terminal experience:

1. Install Windows Terminal from Microsoft Store
2. Set WSL2 as default profile
3. Use a Nerd Font for proper icon display

EOF
}

# Create useful aliases for WSL2
info "Creating WSL2 aliases..."
cat >> "$HOME/.config/shell/wsl2-aliases.sh" << 'EOF'
# WSL2 specific aliases
alias win='cd /mnt/c/Users/$USER'
alias desk='cd /mnt/c/Users/$USER/Desktop'
alias down='cd /mnt/c/Users/$USER/Downloads'
alias docs='cd /mnt/c/Users/$USER/Documents'

# Windows program aliases
alias notepad='notepad.exe'
alias code='code.exe'
alias subl='subl.exe'

# Network utilities
alias ifconfig='ip addr'
alias myip='curl -s https://api.ipify.org && echo'
EOF

setup_1password_windows
setup_windows_terminal

info "WSL2 setup complete!"
info "Please restart your shell or run: source ~/.zshrc"