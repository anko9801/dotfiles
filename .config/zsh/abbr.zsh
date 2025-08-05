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

# Git abbreviations (using actual aliases from gitconfig)
abbr -S g="git"
abbr -S gst="git st"         # status -sb
abbr -S gsw="git sw"         # switch
abbr -S gf="git f"           # fetch --prune
abbr -S gpl="git pl"         # pull (ff-only)
abbr -S gps="git ps"         # push
abbr -S glg="git lg"         # log --graph
abbr -S gla="git la"         # log --all
abbr -S gdf="git df"         # diff --color-words
abbr -S gstaged="git staged" # diff --staged
abbr -S gamend="git amend"   # commit --amend --no-edit
abbr -S gundo="git undo"     # reset HEAD~1 --mixed
abbr -S gunstage="git unstage" # reset HEAD --
abbr -S gcleanup="git cleanup" # delete merged branches
abbr -S gopen="git open"     # gh browse
abbr -S gcz="czg"            # conventional commits

# Docker abbreviations
abbr -S d="docker"
abbr -S dc="docker-compose"
abbr -S dps="docker ps"
abbr -S dpsa="docker ps -a"
abbr -S di="docker images"
abbr -S drm="docker rm"
abbr -S drmi="docker rmi"

# System abbreviations
abbr -S mkdir="mkdir -p"
abbr -S df="df -h"
abbr -S free="free -h"
abbr -S grep="grep --color=auto"

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
abbr -S tk="tmux kill-session"
abbr -S ts="tmux switch"

# Modern CLI replacements (conditional)
if command -v fd &> /dev/null; then
    abbr -S find="fd"
fi
if command -v sd &> /dev/null; then
    abbr -S sed="sd"
fi
if command -v procs &> /dev/null; then
    abbr -S ps="procs"
fi
if command -v btm &> /dev/null; then
    abbr -S top="btm"
    abbr -S htop="btm"
fi
if command -v dust &> /dev/null; then
    abbr -S du="dust"
fi
if command -v bat &> /dev/null; then
    abbr -S cat="bat"
fi
if command -v rg &> /dev/null; then
    abbr -S grep="rg"
fi

# Tool shortcuts
abbr -S gu="gitui"
abbr -S zj="zellij"
abbr -S zja="zellij attach"
abbr -S zjl="zellij list-sessions"
abbr -S zjk="zellij kill-session"

# Development tools
abbr -S py="python3"
abbr -S pip="uv pip"
abbr -S venv="uv venv"
abbr -S m="mise"
abbr -S mi="mise install"
abbr -S mu="mise use"
abbr -S ml="mise list"

# GitHub CLI
abbr -S ghpr="gh pr create"
abbr -S ghpv="gh pr view"
abbr -S ghpl="gh pr list"
abbr -S ghrc="gh repo clone"
abbr -S ghrv="gh repo view --web"

# Shell utilities
abbr -S reload="source \$ZDOTDIR/.zshrc"

# Project navigation
if command -v ghq &> /dev/null; then
    abbr -S gq="ghq get"
    abbr -S gql="ghq list"
    abbr -S gqr="ghq root"
    abbr -S gqcd='cd $(ghq list --full-path | fzf)'
fi

# Quick directory jumps
abbr -S dl="cd ~/Downloads"
abbr -S dt="cd ~/Desktop"
abbr -S pj="cd ~/workspace/projects"
abbr -S dot="cd ~/workspace/projects/dotfiles"