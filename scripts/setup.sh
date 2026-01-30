#!/usr/bin/env bash
# Universal Setup Script
# curl -fsSL https://raw.githubusercontent.com/anko9801/dotfiles/master/scripts/setup.sh | bash

set -euo pipefail

REPO="https://github.com/anko9801/dotfiles.git"
DOTFILES="$HOME/dotfiles"

echo ""
echo "  ╔═══════════════════════════════════════╗"
echo "  ║         Dotfiles Setup Script         ║"
echo "  ╚═══════════════════════════════════════╝"
echo ""

# Detect OS
case "$(uname -s)" in
    Darwin) OS="darwin" ;;
    Linux)
        if grep -qi microsoft /proc/version 2>/dev/null; then
            OS="wsl"
        else
            OS="linux"
        fi
        ;;
    *) echo "Unsupported OS"; exit 1 ;;
esac

echo "[*] Detected: $OS"

# =============================================================================
# 1. Install Nix
# =============================================================================
if ! command -v nix &>/dev/null; then
    echo "[1/4] Installing Nix..."
    curl -fsSL https://install.determinate.systems/nix | sh -s -- install --no-confirm
    . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
else
    echo "[1/4] Nix already installed"
fi

# =============================================================================
# 2. Clone or update dotfiles
# =============================================================================
echo "[2/4] Setting up dotfiles..."
if [[ ! -d "$DOTFILES" ]]; then
    git clone "$REPO" "$DOTFILES"
else
    git -C "$DOTFILES" pull --rebase
fi

# =============================================================================
# 3. Install home-manager and apply config
# =============================================================================
echo "[3/4] Applying configuration..."
cd "$DOTFILES"

case "$OS" in
    darwin)
        # Install nix-darwin if not present
        if ! command -v darwin-rebuild &>/dev/null; then
            nix run nix-darwin -- switch --flake .#anko-mac
        else
            sudo darwin-rebuild switch --flake .#anko-mac
        fi
        ;;
    wsl)
        nix run home-manager -- switch --flake .#anko@wsl
        ;;
    linux)
        nix run home-manager -- switch --flake .#anko@linux
        ;;
esac

# =============================================================================
# 4. Done
# =============================================================================
echo ""
echo "  ╔═══════════════════════════════════════╗"
echo "  ║            Setup Complete!            ║"
echo "  ╚═══════════════════════════════════════╝"
echo ""
echo "  Restart your shell or run: exec zsh"
echo ""
