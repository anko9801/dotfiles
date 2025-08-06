#!/usr/bin/env bash
# macOS system settings and configurations

set -eo pipefail

# Skip if not macOS or disabled
[[ "$(uname)" != "Darwin" ]] && exit 0
[[ "${YADM_BOOTSTRAP_MACOS_SETTINGS:-true}" != "true" ]] && exit 0

# Source logging functions if available
if [[ -z "$(type -t info)" ]]; then
    info() { echo "===> $1"; }
    success() { echo "✓ $1"; }
    error() { echo "✗ $1" >&2; }
    warning() { echo "! $1"; }
fi

info "Applying macOS system settings..."

# Show hidden files in Finder
defaults write com.apple.finder AppleShowAllFiles -bool true

# Enable fast key repeat
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15

# Disable press-and-hold for keys
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

# Apply Finder changes
killall Finder 2>/dev/null || true

success "macOS system settings applied"