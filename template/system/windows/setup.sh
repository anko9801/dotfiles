#!/usr/bin/env bash
# Setup Windows from WSL
# Usage: nix run .#windows (from dotfiles directory)
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

# Build Windows config (uses the "windows" host from config.nix)
echo "[1/2] Building Windows configuration..."
out=$(nix build "$dotfiles#homeConfigurations.windows.activationPackage" \
  --no-link --print-out-paths --impure 2>/dev/null) || true

if [ -n "$out" ]; then
  src="$out/home-files"
  echo "  Built: $out"

  # Deploy git config
  if [ -f "$src/.config/git/config" ]; then
    cp -f "$src/.config/git/config" "$WIN_HOME/.gitconfig" 2>/dev/null &&
      echo "  - .gitconfig" || echo "  - .gitconfig (skipped: permission denied)"
  fi
else
  echo "  No 'windows' host defined in config.nix, skipping config deployment."
  echo "  To enable: uncomment the 'windows' host in config.nix"
fi

# Install packages via winget
echo "[2/2] Installing packages..."
if command -v winget.exe &>/dev/null; then
  winget.exe import -i "$dotfiles/system/windows/winget-packages.json" \
    --accept-package-agreements --accept-source-agreements \
    --ignore-unavailable 2>/dev/null || true
  echo "  Packages installed"
else
  echo "  winget not found, skipping packages"
fi

echo "=== Windows setup complete! ==="
