#!/usr/bin/env bash
#
# macOS Nix Setup Script
# Usage: curl -fsSL https://raw.githubusercontent.com/anko9801/dotfiles/master/scripts/setup-darwin.sh | bash
#
set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

info() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

# Configuration
DOTFILES_REPO="https://github.com/anko9801/dotfiles.git"
DOTFILES_DIR="$HOME/dotfiles"
DARWIN_CONFIG="usamidaiki-mac"  # Change to your config name

echo ""
echo "=============================================="
echo "  macOS Nix Environment Setup"
echo "=============================================="
echo ""

# Detect username
USERNAME=$(whoami)
info "Detected user: $USERNAME"

# Detect architecture
ARCH=$(uname -m)
if [[ "$ARCH" == "arm64" ]]; then
    info "Detected Apple Silicon (aarch64-darwin)"
else
    info "Detected Intel Mac (x86_64-darwin)"
fi

# Step 1: Check if Nix is already installed
info "Checking for existing Nix installation..."
if command -v nix &>/dev/null; then
    success "Nix is already installed: $(nix --version)"
    NIX_INSTALLED=true
else
    NIX_INSTALLED=false
    warn "Nix is not installed"
fi

# Step 2: Clean up existing Nix volume if needed
if ! $NIX_INSTALLED; then
    info "Checking for existing Nix volumes..."
    NIX_VOLUME=$(diskutil list | grep -i "Nix Store" | awk '{print $NF}' || true)

    if [[ -n "$NIX_VOLUME" ]]; then
        warn "Found existing Nix volume: $NIX_VOLUME"
        echo ""
        read -p "Delete existing Nix volume? (Y/n): " -n 1 -r
        echo ""
        if [[ ! $REPLY =~ ^[Nn]$ ]]; then
            info "Deleting Nix volume..."
            # Try to unmount first
            sudo diskutil unmount force "$NIX_VOLUME" 2>/dev/null || true
            # Delete the volume
            if ! sudo diskutil apfs deleteVolume "$NIX_VOLUME" 2>/dev/null; then
                warn "Standard delete failed, trying force delete..."
                sudo diskutil apfs deleteVolume "$NIX_VOLUME" -force 2>/dev/null || true
            fi
            success "Nix volume deleted"
        fi
    fi

    # Also clean up any leftover Nix files
    if [[ -d "/nix" ]]; then
        warn "Found /nix directory"
        read -p "Remove /nix directory? (Y/n): " -n 1 -r
        echo ""
        if [[ ! $REPLY =~ ^[Nn]$ ]]; then
            sudo rm -rf /nix 2>/dev/null || true
            success "Removed /nix directory"
        fi
    fi

    # Remove old Nix config files
    for f in /etc/bashrc /etc/zshrc /etc/bash.bashrc; do
        if [[ -f "${f}.backup-before-nix" ]]; then
            info "Restoring ${f} from backup..."
            sudo mv "${f}.backup-before-nix" "$f" 2>/dev/null || true
        fi
    done
fi

# Step 3: Install Nix
if ! $NIX_INSTALLED; then
    info "Installing Nix..."
    echo ""

    # Use official Nix installer (works on both Intel and Apple Silicon)
    info "Using official Nix installer..."
    sh <(curl -L https://nixos.org/nix/install) --daemon

    success "Nix installed successfully!"

    # Source Nix
    if [[ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
        . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
    elif [[ -f /etc/profile.d/nix.sh ]]; then
        . /etc/profile.d/nix.sh
    fi
fi

# Verify Nix is available
if ! command -v nix &>/dev/null; then
    error "Nix installation failed or shell needs to be restarted. Please run: exec \$SHELL"
fi

# Step 4: Clone dotfiles if not present
if [[ ! -d "$DOTFILES_DIR" ]]; then
    info "Cloning dotfiles repository..."
    git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
    success "Dotfiles cloned to $DOTFILES_DIR"
else
    info "Dotfiles already exist at $DOTFILES_DIR"
    read -p "Pull latest changes? (Y/n): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        git -C "$DOTFILES_DIR" pull
    fi
fi

# Step 5: Determine correct Darwin configuration
if [[ "$USERNAME" == "usamidaiki" ]]; then
    DARWIN_CONFIG="usamidaiki-mac"
elif [[ "$USERNAME" == "anko" ]]; then
    DARWIN_CONFIG="anko-mac"
else
    warn "Unknown username: $USERNAME"
    read -p "Enter Darwin configuration name (e.g., usamidaiki-mac): " DARWIN_CONFIG
fi

# Add -intel suffix for Intel Macs
if [[ "$ARCH" != "arm64" ]]; then
    DARWIN_CONFIG="${DARWIN_CONFIG}-intel"
fi

info "Using Darwin configuration: $DARWIN_CONFIG"

# Step 6: Backup existing config files
info "Backing up existing configuration files..."
BACKUP_DIR="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"

backup_if_exists() {
    local src="$1"
    if [[ -e "$src" ]]; then
        local dest="$BACKUP_DIR/$(basename "$src")"
        cp -r "$src" "$dest"
        info "Backed up: $src -> $dest"
    fi
}

# Backup files that will be managed by Nix
backup_if_exists "$HOME/.config/zsh"
backup_if_exists "$HOME/.config/atuin"
backup_if_exists "$HOME/.config/mise"
backup_if_exists "$HOME/.config/mcfly"
backup_if_exists "$HOME/.config/gitleaks"
backup_if_exists "$HOME/.config/sheldon"
backup_if_exists "$HOME/.config/git/ghq.toml"
backup_if_exists "$HOME/.ssh/config"
backup_if_exists "$HOME/.zshrc"

success "Backups saved to: $BACKUP_DIR"

# Step 7: Apply nix-darwin configuration
info "Applying nix-darwin configuration..."
echo ""

cd "$DOTFILES_DIR"

# First run: bootstrap nix-darwin
if ! command -v darwin-rebuild &>/dev/null; then
    info "Bootstrapping nix-darwin..."
    nix run nix-darwin -- switch --flake ".#$DARWIN_CONFIG"
else
    info "Running darwin-rebuild..."
    darwin-rebuild switch --flake ".#$DARWIN_CONFIG"
fi

success "nix-darwin configuration applied!"

# Step 8: Post-setup cleanup
echo ""
info "Post-setup tasks..."

# Remove old config files (now managed by Nix)
read -p "Remove old config files that are now managed by Nix? (y/N): " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    rm -rf "$HOME/.config/zsh" 2>/dev/null || true
    rm -rf "$HOME/.config/atuin/config.toml" 2>/dev/null || true
    rm -rf "$HOME/.config/mise/config.toml" 2>/dev/null || true
    rm -rf "$HOME/.config/mcfly" 2>/dev/null || true
    rm -rf "$HOME/.config/gitleaks/config.toml" 2>/dev/null || true
    rm -rf "$HOME/.config/sheldon" 2>/dev/null || true
    rm -rf "$HOME/.config/git/ghq.toml" 2>/dev/null || true
    rm -rf "$HOME/.ssh/config.d/oracle.conf" 2>/dev/null || true
    success "Old config files removed"
fi

# Step 9: Done!
echo ""
echo "=============================================="
echo -e "${GREEN}  Setup Complete!${NC}"
echo "=============================================="
echo ""
echo "Your macOS is now configured with Nix!"
echo ""
echo "Commands:"
echo "  darwin-rebuild switch --flake ~/dotfiles#$DARWIN_CONFIG  # Apply changes"
echo "  nix flake update ~/dotfiles                              # Update flake inputs"
echo "  home-manager generations                                 # List generations"
echo ""
echo "Backups are stored in: $BACKUP_DIR"
echo ""
echo "Please restart your terminal or run: exec \$SHELL"
echo ""
