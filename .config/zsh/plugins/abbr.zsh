#!/usr/bin/env zsh
# Abbreviations using zsh-abbr
# This file is sourced after zsh-abbr is loaded

# Only initialize if abbr is available
command -v abbr &>/dev/null || return

# Check if already initialized
abbr list 2>/dev/null | grep -q "^g=" && return

# ==============================================================================
# Modern CLI replacements
# ==============================================================================
if command -v gomi &>/dev/null; then
    abbr -S rm="gomi"
else
    abbr -S rm="rm -i"
fi

if command -v eza &>/dev/null; then
    abbr -S ls="eza"
    abbr -S ll="eza -l"
    abbr -S la="eza -la"
    abbr -S lt="eza --tree"
    abbr -S lta="eza --tree -a"
else
    abbr -S ls="ls --color=auto"
    abbr -S ll="ls -lah"
    abbr -S la="ls -A"
    abbr -S l="ls -CF"
fi

# Conditional modern tools
command -v fd &>/dev/null && abbr -S find="fd"
command -v sd &>/dev/null && abbr -S sed="sd"
command -v procs &>/dev/null && abbr -S ps="procs"
command -v btm &>/dev/null && abbr -S top="btm" && abbr -S htop="btm"
command -v dust &>/dev/null && abbr -S du="dust"
command -v bat &>/dev/null && abbr -S cat="bat"
command -v rg &>/dev/null && abbr -S grep="rg"

# ==============================================================================
# Safety aliases
# ==============================================================================
abbr -S cp="cp -i"
abbr -S mv="mv -i"

# ==============================================================================
# Navigation
# ==============================================================================
abbr -S ..="cd .."
abbr -S ...="cd ../.."
abbr -S ....="cd ../../.."
abbr -S dl="cd ~/Downloads"
abbr -S dt="cd ~/Desktop"
abbr -S pj="cd ~/workspace/projects"
abbr -S dot="cd ~/workspace/projects/dotfiles"

# ==============================================================================
# Git (based on gitconfig aliases)
# ==============================================================================
abbr -S g="git"
abbr -S gst="git st"
abbr -S gsw="git sw"
abbr -S gf="git f"
abbr -S gpl="git pl"
abbr -S gps="git ps"
abbr -S glg="git lg"
abbr -S gla="git la"
abbr -S gdf="git df"
abbr -S gstaged="git staged"
abbr -S gamend="git amend"
abbr -S gundo="git undo"
abbr -S gunstage="git unstage"
abbr -S gcleanup="git cleanup"
abbr -S gopen="git open"
abbr -S gcz="czg"

# ==============================================================================
# GitHub CLI
# ==============================================================================
abbr -S ghpr="gh pr create"
abbr -S ghpv="gh pr view"
abbr -S ghpl="gh pr list"
abbr -S ghrc="gh repo clone"
abbr -S ghrv="gh repo view --web"

# ==============================================================================
# Docker
# ==============================================================================
abbr -S d="docker"
abbr -S dc="docker-compose"
abbr -S dps="docker ps"
abbr -S dpsa="docker ps -a"
abbr -S di="docker images"
abbr -S drm="docker rm"
abbr -S drmi="docker rmi"

# ==============================================================================
# Package managers
# ==============================================================================
# Homebrew
abbr -S bi="brew install"
abbr -S bu="brew update"
abbr -S bug="brew upgrade"
abbr -S bs="brew search"

# mise
abbr -S m="mise"
abbr -S mi="mise install"
abbr -S mu="mise use"
abbr -S ml="mise list"

# Python
abbr -S py="python3"
abbr -S pip="uv pip"
abbr -S venv="uv venv"

# ==============================================================================
# Editors
# ==============================================================================
abbr -S v="vim"
abbr -S nv="nvim"
abbr -S c="code"

# ==============================================================================
# Terminal multiplexers
# ==============================================================================
# tmux
abbr -S t="tmux"
abbr -S ta="tmux attach"
abbr -S tn="tmux new"
abbr -S tl="tmux list-sessions"
abbr -S tk="tmux kill-session"
abbr -S ts="tmux switch"

# zellij
abbr -S zj="zellij"
abbr -S zja="zellij attach"
abbr -S zjl="zellij list-sessions"
abbr -S zjk="zellij kill-session"

# ==============================================================================
# Repository management
# ==============================================================================
if command -v ghq &>/dev/null; then
    abbr -S gq="ghq get"
    abbr -S gql="ghq list"
    abbr -S gqr="ghq root"
    abbr -S gqcd='cd $(ghq list --full-path | fzf)'
fi

# ==============================================================================
# Utilities
# ==============================================================================
abbr -S mkdir="mkdir -p"
abbr -S df="df -h"
abbr -S free="free -h"
abbr -S h="history"
abbr -S j="jobs"
abbr -S gu="gitui"
abbr -S reload="source \$ZDOTDIR/.zshrc"