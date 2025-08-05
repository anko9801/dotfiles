#!/usr/bin/env zsh
# Useful shell functions

# ghq + fzf integration - quickly cd to repositories
ghq-fzf() {
    local selected
    selected=$(ghq list | fzf --height=40% --layout=reverse --border --preview "cat $(ghq root)/{}/README.md 2>/dev/null || ls -la $(ghq root)/{}")
    if [[ -n "$selected" ]]; then
        cd "$(ghq root)/$selected" || return
    fi
}

# Alias for easier access
alias gq='ghq-fzf'

# ghq + fzf - open in editor
ghq-code() {
    local selected
    selected=$(ghq list | fzf --height=40% --layout=reverse --border)
    if [[ -n "$selected" ]]; then
        code "$(ghq root)/$selected"
    fi
}

# Git clone with ghq
alias gc='ghq get'

# Create new directory and cd into it
mkcd() {
    mkdir -p "$1" && cd "$1" || return
}

# Extract various archive formats
extract() {
    if [ -f "$1" ]; then
        case "$1" in
            *.tar.bz2)   tar xjf "$1"   ;;
            *.tar.gz)    tar xzf "$1"   ;;
            *.bz2)       bunzip2 "$1"   ;;
            *.rar)       unrar x "$1"   ;;
            *.gz)        gunzip "$1"    ;;
            *.tar)       tar xf "$1"    ;;
            *.tbz2)      tar xjf "$1"   ;;
            *.tgz)       tar xzf "$1"   ;;
            *.zip)       unzip "$1"     ;;
            *.Z)         uncompress "$1";;
            *.7z)        7z x "$1"      ;;
            *)           echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# fzf-powered cd
fcd() {
    local dir
    dir=$(fd --type d --hidden --follow --exclude .git 2>/dev/null | fzf --height=40% --layout=reverse --border --preview 'tree -C {} | head -100') && cd "$dir" || return
}

# Kill process with fzf
fkill() {
    local pid
    pid=$(ps aux | sed 1d | fzf --height=40% --layout=reverse --border --multi | awk '{print $2}')
    if [[ -n "$pid" ]]; then
        echo "$pid" | xargs kill -9
    fi
}

# Git branch switch with fzf
fbr() {
    local branches branch
    branches=$(git branch --all | grep -v HEAD) &&
    branch=$(echo "$branches" | fzf --height=40% --layout=reverse --border -d $(( 2 + $(wc -l <<< "$branches") )) +m) &&
    git checkout "$(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##")"
}

# Docker container exec with fzf
dexec() {
    local container
    container=$(docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}" | sed 1d | fzf --height=40% --layout=reverse --border | awk '{print $1}')
    if [[ -n "$container" ]]; then
        docker exec -it "$container" /bin/bash || docker exec -it "$container" /bin/sh
    fi
}

# Search history with fzf
fh() {
    print -z $( ([ -n "$ZSH_NAME" ] && fc -l 1 || history) | fzf --height=40% --layout=reverse --border --tac | sed -E 's/ *[0-9]*\*? *//' | sed -E 's/\\/\\\\/g')
}