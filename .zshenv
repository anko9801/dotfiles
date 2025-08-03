# Minimal .zshenv - Required for proper environment setup
# This file MUST exist in ~ due to zsh design

# XDG Base Directory Specification
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_STATE_HOME="$HOME/.local/state"

# Zsh configuration directory
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"