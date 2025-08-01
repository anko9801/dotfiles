# XDG Base Directory Specification
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_STATE_HOME="$HOME/.local/state"

# Zsh configuration directory
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"

# Application XDG compliance
export VIMINIT='let $MYVIMRC="$XDG_CONFIG_HOME/vim/vimrc" | source $MYVIMRC'
export INPUTRC="$XDG_CONFIG_HOME/readline/inputrc"
export LESSHISTFILE="$XDG_CACHE_HOME/less/history"

# Path additions
export PATH="$HOME/.local/bin:$PATH"

# Tool-specific paths (if installed)
if [ -d "$HOME/.cargo" ]; then
    . "$HOME/.cargo/env"
fi

# Mise (version manager)
if command -v mise >/dev/null 2>&1; then
    eval "$(mise activate zsh)"
fi