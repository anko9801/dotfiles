# ─────────────────────────────────────────────────────────────────
# Global Aliases (pipe shortcuts)
# Usage: dmesg G CPU, cat file L, ls W
# ─────────────────────────────────────────────────────────────────
alias -g G='| grep'
alias -g L='| less'
alias -g H='| head'
alias -g T='| tail'
alias -g W='| wc'
alias -g S='| sort'
alias -g U='| uniq'
alias -g J='| jq'
# Y (yank to clipboard) - uses pbcopy from functions.zsh (OSC 52)
alias -g Y='| pbcopy'

# ─────────────────────────────────────────────────────────────────
# Suffix Aliases (open files by extension)
# Usage: file.md → $EDITOR file.md, script.py → python script.py
# ─────────────────────────────────────────────────────────────────
alias -s {md,markdown,txt,nix,json,yaml,yml,toml}="$EDITOR"
alias -s {gz,tgz,zip,bz2,tbz,xz,tar,7z,rar,zst}='ouch decompress'
alias -s py='python'
alias -s rb='ruby'
alias -s js='node'
alias -s ts='deno run'
alias -s go='go run'
alias -s lua='lua'
alias -s sh='bash'
# Git clone by pasting URL: git@github.com:user/repo.git → git clone ...
alias -s git='git clone'

# ─────────────────────────────────────────────────────────────────
# Abbreviations (deferred to run after zsh-abbr loads)
# ─────────────────────────────────────────────────────────────────
_init_abbr() {
  # Modern CLI replacements (abbr for learning, see expansion)
  abbr -S -q find="fd"
  abbr -S -q top="btm"
  abbr -S -q htop="btm"
  abbr -S -q du="dust"
  abbr -S -q ps="procs"
  abbr -S -q sed="sd"

  # Convenience flags
  abbr -S -q curl="curl -fsSL"
  abbr -S -q df="df -h"
  abbr -S -q free="free -h"

  # Navigation
  abbr -S -q ..="cd .."
  abbr -S -q ...="cd ../.."
  abbr -S -q ....="cd ../../.."

  # Git
  abbr -S -q gs="git st"
  abbr -S -q gl="git lg"
  abbr -S -q gp="git pull"
  abbr -S -q gP="git push"
  abbr -S -q 'gP!'="git please"
  abbr -S -q gw="git wt"

  # Tools
  abbr -S -q lzg="lazygit"
  abbr -S -q lzd="lazydocker"

  # Development
  abbr -S -q py="python3"
  abbr -S -q pip="uv pip"
  abbr -S -q venv="uv venv"

  # GitHub CLI
  abbr -S -q ghpr="gh pr create"
  abbr -S -q ghpv="gh pr view"
  abbr -S -q ghpl="gh pr list"
  abbr -S -q ghrc="gh repo clone"
  abbr -S -q ghrv="gh repo view --web"

  # Claude Code (claude → YOLO mode, c → safe mode)
  abbr -S -q c="claude"
  abbr -S -q cc="claude --dangerously-skip-permissions"


  # Make abbreviations available in Tab completion (command position only)
  _complete_abbr() {
    # Only complete abbreviations for first word (command position)
    [[ $CURRENT -ne 1 ]] && return 1
    local -a _abbrs
    _abbrs=(${(f)"$(abbr list-abbreviations 2>/dev/null | cut -d= -f1 | tr -d \")"})
    [[ ${#_abbrs} -gt 0 ]] && compadd -V abbr -X 'abbreviations' -- "${_abbrs[@]}"
    return 1
  }
  zstyle -g _completers ':completion:*' completer
  zstyle ':completion:*' completer _complete_abbr ${_completers[@]}
}

# Defer abbr initialization (runs after zsh-abbr loads)
zsh-defer _init_abbr
