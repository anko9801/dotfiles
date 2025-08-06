#!/usr/bin/env bash
# WSL integration and configurations

set -eo pipefail

# Skip if not WSL
[[ ! -f /proc/sys/fs/binfmt_misc/WSLInterop ]] && exit 0

# Source logging functions if available
if [[ -z "$(type -t info)" ]]; then
    info() { echo "===> $1"; }
    success() { echo "✓ $1"; }
    error() { echo "✗ $1" >&2; }
    warning() { echo "! $1"; }
fi

info "Applying WSL integration settings..."

# Disable Windows PATH pollution
if ! grep -q '\[interop\]' /etc/wsl.conf 2>/dev/null; then
    if [[ ! -f /etc/wsl.conf ]]; then
        echo -e "[interop]\nappendWindowsPath = false" | sudo tee /etc/wsl.conf >/dev/null
    else
        echo -e "\n[interop]\nappendWindowsPath = false" | sudo tee -a /etc/wsl.conf >/dev/null
    fi
fi

# Create Windows home symlink
if [[ ! -e "$HOME/winhome" ]]; then
    if command -v wslpath &>/dev/null; then
        WINHOME=$(wslpath "$(cmd.exe /c 'echo %USERPROFILE%' 2>/dev/null | tr -d '\r')")
        [[ -d "$WINHOME" ]] && ln -s "$WINHOME" "$HOME/winhome"
    fi
fi

# Configure Git for WSL
git config --global core.autocrlf input
git config --global core.filemode false

success "WSL integration configured"