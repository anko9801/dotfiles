# XDG Base Directory Specification
# These MUST be in .zshenv for proper bootstrap and tool configuration
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_STATE_HOME="$HOME/.local/state"

# Zsh configuration directory
# This MUST be here so zsh can find its config files
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"