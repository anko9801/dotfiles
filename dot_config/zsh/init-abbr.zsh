#!/usr/bin/env zsh
# Initialize zsh-abbr abbreviations efficiently

# Early exit if abbr not available or already initialized
command -v abbr &>/dev/null || return
abbr list 2>/dev/null | grep -q "^g=" && return

# Modern CLI tool abbreviations (conditional on availability)
if command -v gomi &> /dev/null; then
    abbr -S rm="gomi"
else
    abbr -S rm="rm -i"
fi

if command -v eza &> /dev/null; then
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

# Safety and utility abbreviations
abbr -S cp="cp -i"
abbr -S mv="mv -i"

# Navigation abbreviations
abbr -S ..="cd .."
abbr -S ...="cd ../.."
abbr -S ....="cd ../../.."

# Git abbreviations
abbr -S g="git"
abbr -S ga="git add"
abbr -S gb="git branch"
abbr -S gc="git commit"
abbr -S gca="git commit --amend"
abbr -S gcm="git commit -m"
abbr -S gco="git checkout"
abbr -S gcp="git cherry-pick"
abbr -S gd="git diff"
abbr -S gf="git fetch"
abbr -S gl="git log"
abbr -S gm="git merge"
abbr -S gp="git push"
abbr -S gpl="git pull"
abbr -S gr="git rebase"
abbr -S gri="git rebase -i"
abbr -S gs="git status"
abbr -S gst="git stash"

# Docker abbreviations
abbr -S d="docker"
abbr -S dc="docker-compose"
abbr -S dps="docker ps"
abbr -S dpsa="docker ps -a"
abbr -S di="docker images"
abbr -S drm="docker rm"
abbr -S drmi="docker rmi"

# System abbreviations
abbr -S ll="ls -la"
abbr -S la="ls -A"
abbr -S l="ls -CF"
abbr -S ..="cd .."
abbr -S ...="cd ../.."
abbr -S ....="cd ../../.."
abbr -S mkdir="mkdir -p"

# Editors
abbr -S v="vim"
abbr -S nv="nvim"
abbr -S c="code"

# Package managers
abbr -S bi="brew install"
abbr -S bu="brew update"
abbr -S bug="brew upgrade"
abbr -S bs="brew search"

# Misc
abbr -S h="history"
abbr -S j="jobs"
abbr -S t="tmux"
abbr -S ta="tmux attach"
abbr -S tn="tmux new"
abbr -S tl="tmux list-sessions"

# Modern CLI replacements
abbr -S find="fd"
abbr -S sed="sd"
abbr -S ps="procs"
abbr -S top="btm"
abbr -S htop="btm"
abbr -S du="dust"

# Tool shortcuts
abbr -S gu="gitui"
abbr -S zj="zellij"
abbr -S zja="zellij attach"
abbr -S zjl="zellij list-sessions"
abbr -S zjk="zellij kill-session"

# HTTP and file tools
abbr -S http="httpie"
abbr -S mdview="glow"
abbr -S mdp="glow -p"
abbr -S yaml="yq"

# Shell utilities
abbr -S reload="source \$ZDOTDIR/.zshrc"