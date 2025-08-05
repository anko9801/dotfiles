#!/usr/bin/env zsh
# FZF-tab configuration

# Git checkout completion
zstyle ':completion:*:git-checkout:*' sort false

# Descriptions format
zstyle ':completion:*:descriptions' format '[%d]'

# Preview for directory completion
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'

# Switch between groups with , and .
zstyle ':fzf-tab:*' switch-group ',' '.'

# Use tmux popup if available
if [[ -n "$TMUX" ]]; then
    zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup
fi

# Configure preview window
zstyle ':fzf-tab:*' fzf-flags --height=40% --layout=reverse --border --preview-window=right:50%:wrap

# File preview
zstyle ':fzf-tab:complete:*:*' fzf-preview '
    if [[ -d $realpath ]]; then
        eza -1 --color=always $realpath
    elif [[ -f $realpath ]]; then
        bat --color=always --style=numbers --line-range=:100 $realpath 2>/dev/null || cat $realpath
    else
        echo $realpath
    fi
'

# Process preview for kill command
zstyle ':fzf-tab:complete:kill:argument-rest' fzf-preview 'ps aux | grep -v grep | grep "${${(@s: :)words[2]}[2]}"'

# Git completion preview
zstyle ':fzf-tab:complete:git-(add|diff|restore):*' fzf-preview 'git diff --color=always $realpath'
zstyle ':fzf-tab:complete:git-log:*' fzf-preview 'git log --oneline --color=always $realpath'
zstyle ':fzf-tab:complete:git-show:*' fzf-preview 'git show --color=always $realpath'

# systemctl preview
zstyle ':fzf-tab:complete:systemctl-*:*' fzf-preview 'SYSTEMD_COLORS=1 systemctl status $word'

# Environment variable preview
zstyle ':fzf-tab:complete:(-command-|-parameter-|-brace-parameter-|export|unset|expand):*' fzf-preview 'echo ${(P)word}'

# Man page preview
zstyle ':fzf-tab:complete:man:*' fzf-preview 'man -P cat $word | head -100'