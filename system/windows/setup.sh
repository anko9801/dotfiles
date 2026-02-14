#!/usr/bin/env bash
# Setup Windows from WSL
# Usage: nix run .#setup-windows (from dotfiles directory)
set -e

# Get Windows user
WIN_USER="${WINDOWS_USER:-$(cmd.exe /c "echo %USERNAME%" 2>/dev/null | tr -d '\r')}"
WIN_HOME="/mnt/c/Users/$WIN_USER"

if [ ! -d "$WIN_HOME" ]; then
  echo "Error: Windows home not found: $WIN_HOME"
  exit 1
fi

echo "=== Setting up Windows for $WIN_USER ==="
dotfiles="$(cd "$(dirname "$0")/../.." && pwd)"

# Build Windows config
echo "[1/4] Building Windows configuration..."
out=$(nix build "$dotfiles#homeConfigurations.windows.activationPackage" \
  --no-link --print-out-paths --impure)
src="$out/home-files"
echo "  Built: $out"

# Deploy config files
echo "[2/4] Deploying configuration files..."

# Git
if [ -f "$src/.config/git/config" ]; then
  cp -f "$src/.config/git/config" "$WIN_HOME/.gitconfig" 2>/dev/null &&
    echo "  - .gitconfig" || echo "  - .gitconfig (skipped: permission denied)"
fi

# VS Code
vscode_dir="$WIN_HOME/AppData/Roaming/Code/User"
if [ -d "$vscode_dir" ] && [ -f "$src/.config/Code/User/settings.json" ]; then
  cp -f "$src/.config/Code/User/settings.json" "$vscode_dir/settings.json" 2>/dev/null &&
    echo "  - VS Code settings" || echo "  - VS Code settings (skipped: permission denied)"
fi

# Windows Terminal
wt_dir="$WIN_HOME/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState"
if [ -d "$wt_dir" ] && [ -f "$dotfiles/system/windows/windows-terminal.json" ]; then
  cp -f "$dotfiles/system/windows/windows-terminal.json" "$wt_dir/settings.json" 2>/dev/null &&
    echo "  - Windows Terminal settings" || echo "  - Windows Terminal settings (skipped: permission denied)"
fi

# komorebi
komorebi_dir="$WIN_HOME/.config/komorebi"
mkdir -p "$komorebi_dir" 2>/dev/null || true
if [ -f "$dotfiles/system/windows/komorebi.json" ]; then
  cp -f "$dotfiles/system/windows/komorebi.json" "$komorebi_dir/komorebi.json" 2>/dev/null &&
    echo "  - komorebi config" || echo "  - komorebi config (skipped: permission denied)"
fi

# whkd
mkdir -p "$WIN_HOME/.config" 2>/dev/null || true
if [ -f "$dotfiles/system/windows/whkdrc" ]; then
  cp -f "$dotfiles/system/windows/whkdrc" "$WIN_HOME/.config/whkdrc" 2>/dev/null &&
    echo "  - whkd config" || echo "  - whkd config (skipped: permission denied)"
fi

# Fonts
echo "[3/4] Installing fonts..."
fonts_dir="$WIN_HOME/AppData/Local/Microsoft/Windows/Fonts"
mkdir -p "$fonts_dir"
font_pkg=$(nix build nixpkgs#moralerspace --no-link --print-out-paths 2>/dev/null || true)
if [ -n "$font_pkg" ] && [ -d "$font_pkg" ]; then
  cp -n "$font_pkg"/share/fonts/moralerspace/MoralerspaceNeon*.ttf "$fonts_dir/" 2>/dev/null &&
    echo "  - Moralerspace Neon" || true
fi

# Install packages
echo "[4/4] Installing packages..."
if command -v winget.exe &>/dev/null; then
  winget.exe import -i "$dotfiles/system/windows/winget-packages.json" \
    --accept-package-agreements --accept-source-agreements \
    --ignore-unavailable 2>/dev/null || true
  echo "  Packages installed"
else
  echo "  winget not found, skipping packages"
fi

echo "=== Windows setup complete! ==="
