#!/usr/bin/env zsh
# History configuration

export HISTFILE=${HOME}/.zhistory
export HISTSIZE=10000
export SAVEHIST=10000

# History options
setopt EXTENDED_HISTORY       # Record timestamp of command
setopt SHARE_HISTORY          # Share history between sessions
setopt HIST_IGNORE_ALL_DUPS   # Don't record duplicates
setopt HIST_IGNORE_SPACE      # Don't record commands starting with space
setopt HIST_VERIFY            # Show command with history expansion before running
setopt HIST_REDUCE_BLANKS     # Remove superfluous blanks
setopt INC_APPEND_HISTORY     # Add commands immediately
setopt HIST_EXPIRE_DUPS_FIRST # Expire duplicates first when trimming