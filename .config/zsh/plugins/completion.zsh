#!/usr/bin/env zsh
# Completion system configuration

# ==============================================================================
# Advanced completion styles
# ==============================================================================
# Note: Basic styles are in .zshrc, these are additional configurations

# Enable menu selection (already in .zshrc)
# zstyle ':completion:*:default' menu select=2

# Verbose completion
zstyle ':completion:*' verbose yes

# Completion strategy
zstyle ':completion:*' completer _expand _complete _match _prefix _approximate _list _history

# Formatting
zstyle ':completion:*:messages' format '%F{yellow}%d%f'
zstyle ':completion:*:warnings' format '%F{red}No matches for:%f %F{yellow}%d%f'
zstyle ':completion:*:descriptions' format '%F{yellow}completing %B%d%b%f'
zstyle ':completion:*:corrections' format '%F{yellow}%B%d %f%F{red}(errors: %e)%b%f'
zstyle ':completion:*:options' description 'yes'
zstyle ':completion:*' group-name ''

# ==============================================================================
# Colors
# ==============================================================================
export LS_COLORS='di=94:ln=35:so=32:pi=33:ex=31:bd=46;94:cd=43;94:su=41;30:sg=46;30:tw=42;30:ow=43;30'
# zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}  # Already in .zshrc

# ==============================================================================
# Matching
# ==============================================================================
# Case insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# Partial completion
zstyle ':completion:*' list-suffixes
zstyle ':completion:*' expand prefix suffix

# ==============================================================================
# Caching
# ==============================================================================
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/zsh/zcompcache"

# ==============================================================================
# Special completions
# ==============================================================================
# Kill command completion
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

# Man pages
zstyle ':completion:*:manuals' separate-sections true
zstyle ':completion:*:manuals.(^1*)' insert-sections true

# SSH/SCP/RSYNC
zstyle ':completion:*:(scp|rsync):*' tag-order 'hosts:-host:host hosts:-domain:domain hosts:-ipaddr:ip\ address *'
zstyle ':completion:*:(scp|rsync):*' group-order users files all-files hosts-domain hosts-host hosts-ipaddr
zstyle ':completion:*:ssh:*' tag-order 'hosts:-host:host hosts:-domain:domain hosts:-ipaddr:ip\ address *'
zstyle ':completion:*:ssh:*' group-order users hosts-domain hosts-host users hosts-ipaddr

# ==============================================================================
# Ignored patterns
# ==============================================================================
zstyle ':completion:*:functions' ignored-patterns '(_*|pre(cmd|exec))'
zstyle ':completion:*:*:*:users' ignored-patterns '_*'

# ==============================================================================
# Spell correction prompt
# ==============================================================================
SPROMPT="correct: %F{red}%R%f -> %F{green}%r%f ? [No/Yes/Abort/Edit]"