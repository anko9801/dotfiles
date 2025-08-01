# Bash-specific interactive shell configuration
# This file is only sourced for interactive bash sessions

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# Source common shell configuration
[ -f "$XDG_CONFIG_HOME/shell/aliases" ] && . "$XDG_CONFIG_HOME/shell/aliases"

# Load OS-specific environment
case "$(uname -s)" in
    Darwin*)
        [ -f "$XDG_CONFIG_HOME/shell/env##os.Darwin" ] && . "$XDG_CONFIG_HOME/shell/env##os.Darwin"
        ;;
    Linux*)
        [ -f "$XDG_CONFIG_HOME/shell/env##os.Linux" ] && . "$XDG_CONFIG_HOME/shell/env##os.Linux"
        ;;
esac

# Modern CLI tools (bash-compatible)
if command -v starship >/dev/null 2>&1; then
    eval "$(starship init bash)"
fi

if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init --cmd cd bash)"
fi

if command -v atuin >/dev/null 2>&1; then
    eval "$(atuin init bash)"
fi

# History settings
export HISTFILE="$XDG_STATE_HOME/bash/history"
export HISTSIZE=10000
export SAVEHIST=10000
export HISTCONTROL=ignoredups:erasedups

# Create history directory if it doesn't exist
[ ! -d "$XDG_STATE_HOME/bash" ] && mkdir -p "$XDG_STATE_HOME/bash"