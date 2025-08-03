#!/usr/bin/env zsh
# Zsh plugins configuration

# Load plugins
zinit light Aloxaf/fzf-tab
zinit light olets/zsh-abbr

# Configure fzf-tab
# disable sort when completing `git checkout`
zstyle ':completion:*:git-checkout:*' sort false
# set descriptions format to enable group support
zstyle ':completion:*:descriptions' format '[%d]'
# set list-colors to enable filename colorizing
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
# preview directory's content with eza when completing cd
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
# switch group using `,` and `.`
zstyle ':fzf-tab:*' switch-group ',' '.'

# Configure zsh-abbr
export ABBR_SET_EXPANSION_CURSOR=1
export ABBR_GET_AVAILABLE_ABBREVIATION=1

# Define abbreviations
abbr_init() {
    # Git abbreviations
    abbr g="git"
    abbr ga="git add"
    abbr gc="git commit"
    abbr gco="git checkout"
    abbr gd="git diff"
    abbr gl="git log"
    abbr gp="git push"
    abbr gpl="git pull"
    abbr gs="git status"
    
    # Directory navigation
    abbr ..="cd .."
    abbr ...="cd ../.."
    abbr ....="cd ../../.."
    
    # Common commands
    abbr l="eza -la"
    abbr ll="eza -l"
    abbr la="eza -a"
    abbr tree="eza --tree"
    
    # Docker
    abbr d="docker"
    abbr dc="docker compose"
    
    # Kubernetes
    abbr k="kubectl"
    abbr kx="kubectx"
    abbr kn="kubens"
}

# Initialize abbreviations
abbr_init