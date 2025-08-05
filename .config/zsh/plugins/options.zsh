#!/usr/bin/env zsh
# Shell options configuration

# ==============================================================================
# Directory navigation
# ==============================================================================
# setopt AUTO_CD              # Already in .zshrc
# setopt AUTO_PUSHD           # Already in .zshrc
# setopt PUSHD_IGNORE_DUPS    # Already in .zshrc
setopt PUSHD_SILENT           # Don't print directory stack

# ==============================================================================
# Completion
# ==============================================================================
setopt AUTO_MENU              # Show completion menu on tab press
setopt AUTO_PARAM_SLASH       # Add slash after directory completion
setopt AUTO_PARAM_KEYS        # Automatically complete brackets
setopt COMPLETE_IN_WORD       # Complete from cursor position
setopt ALWAYS_LAST_PROMPT     # Keep cursor position when completing
setopt LIST_PACKED            # Compact completion list
setopt LIST_TYPES             # Show file types in completion
setopt MARK_DIRS              # Add slash to directory names

# ==============================================================================
# Expansion and globbing
# ==============================================================================
setopt EXTENDED_GLOB          # Extended globbing patterns
setopt GLOBDOTS               # Match dotfiles without explicit dot
setopt MAGIC_EQUAL_SUBST      # Expand ~= and similar

# ==============================================================================
# Input/Output
# ==============================================================================
# setopt INTERACTIVE_COMMENTS # Already in .zshrc
# setopt PRINT_EIGHT_BIT      # Already in .zshrc
setopt NO_FLOW_CONTROL        # Disable flow control (^S/^Q)
# setopt CORRECT              # Already in .zshrc
# setopt NO_BEEP              # Already in .zshrc

# ==============================================================================
# Job control
# ==============================================================================
setopt LONG_LIST_JOBS         # List jobs in long format
setopt NOTIFY                 # Report job status immediately
setopt NO_HUP                 # Don't kill jobs on shell exit

# ==============================================================================
# Safety
# ==============================================================================
setopt RM_STAR_SILENT         # Don't warn on rm *