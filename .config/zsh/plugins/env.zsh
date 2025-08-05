#!/usr/bin/env zsh
# Environment variables and PATH configuration

# ==============================================================================
# Basic environment
# ==============================================================================
export LANG=ja_JP.UTF-8
export EDITOR=vim
export VISUAL=vim
export PAGER=less
export LESSHISTFILE=-  # Don't save less history
export GPG_TTY=$(tty)

# ==============================================================================
# XDG Base Directory
# ==============================================================================
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

# ==============================================================================
# Tool configuration
# ==============================================================================
# Vim
export VIMINIT='let $MYVIMRC="$XDG_CONFIG_HOME/vim/vimrc" | source $MYVIMRC'
export INPUTRC="$XDG_CONFIG_HOME/readline/inputrc"

# Development
export GOPATH=$HOME/go
export MISE_GLOBAL_CONFIG_FILE="$XDG_CONFIG_HOME/mise/config.toml"

# FZF
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# ==============================================================================
# PATH configuration
# ==============================================================================
typeset -U path  # Remove duplicates
path=(
    "$HOME/.local/bin"
    "$HOME/downloads"
    "$GOPATH/bin"
    "$HOME/.cargo/bin"
    "$HOME/.npm-global/bin"
    $path
)
[[ -d "$HOME/path" ]] && path=("$HOME/path" $path)

# Remove non-existent directories
path=($^path(N))

export PATH

# ==============================================================================
# OS-specific environment
# ==============================================================================
# Source OS-specific environment if exists
[[ -f "$XDG_CONFIG_HOME/zsh/env.zsh" ]] && source "$XDG_CONFIG_HOME/zsh/env.zsh"