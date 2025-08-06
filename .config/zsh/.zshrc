# ==============================================================================
# Zsh Configuration
# ==============================================================================

# ------------------------------------------------------------------------------
# 環境変数
# ------------------------------------------------------------------------------
export LANG=ja_JP.UTF-8
export EDITOR=vim
export VISUAL=vim
export PAGER=less
export LESSHISTFILE=-
export GPG_TTY=$(tty)

# XDG Base Directory
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

# Vim XDG support
export VIMINIT='let $MYVIMRC="$XDG_CONFIG_HOME/vim/vimrc" | source $MYVIMRC'
export INPUTRC="$XDG_CONFIG_HOME/readline/inputrc"

# Development
export GOPATH=$HOME/go
export MISE_GLOBAL_CONFIG_FILE="$XDG_CONFIG_HOME/mise/config.toml"

# FZF
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# ------------------------------------------------------------------------------
# PATH設定
# ------------------------------------------------------------------------------
typeset -U path
path=(
    "$HOME/.local/bin"
    "$GOPATH/bin"
    "$HOME/.cargo/bin"
    "$HOME/.npm-global/bin"
    $path
)
[[ -d "$HOME/downloads" ]] && path=("$HOME/downloads" $path)
[[ -d "$HOME/path" ]] && path=("$HOME/path" $path)
export PATH

# ------------------------------------------------------------------------------
# 履歴設定
# ------------------------------------------------------------------------------
export HISTFILE=${HOME}/.zhistory
export HISTSIZE=10000
export SAVEHIST=10000

setopt EXTENDED_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_VERIFY
setopt HIST_REDUCE_BLANKS

# ------------------------------------------------------------------------------
# 基本オプション
# ------------------------------------------------------------------------------
setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt CORRECT
setopt LIST_PACKED
setopt NO_BEEP
setopt INTERACTIVE_COMMENTS
setopt PRINT_EIGHT_BIT

# ------------------------------------------------------------------------------
# 補完設定
# ------------------------------------------------------------------------------
autoload -Uz compinit
compinit -C

zstyle ':completion:*:default' menu select=2
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' use-cache true
zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/zsh/zcompcache"

# ------------------------------------------------------------------------------
# Sheldon プラグインマネージャー
# ------------------------------------------------------------------------------
eval "$(sheldon source)"

# ------------------------------------------------------------------------------
# カスタム設定の読み込み
# ------------------------------------------------------------------------------
# OS固有の環境変数
[[ -f "$XDG_CONFIG_HOME/zsh/env.zsh" ]] && source "$XDG_CONFIG_HOME/zsh/env.zsh"

# カスタム関数
[[ -f "$XDG_CONFIG_HOME/zsh/functions.zsh" ]] && source "$XDG_CONFIG_HOME/zsh/functions.zsh"

# 略語定義 (loaded after shell plugins via zsh-defer)
[[ -f "$XDG_CONFIG_HOME/zsh/abbr.zsh" ]] && zsh-defer source "$XDG_CONFIG_HOME/zsh/abbr.zsh"

# ------------------------------------------------------------------------------
# ツール初期化
# ------------------------------------------------------------------------------
# mise
command -v mise &>/dev/null && eval "$(mise activate zsh)"

# starship
command -v starship &>/dev/null && eval "$(starship init zsh)"

# zoxide
command -v zoxide &>/dev/null && eval "$(zoxide init --cmd cd --hook pwd zsh)"

# fzf
command -v fzf &>/dev/null && eval "$(fzf --zsh)"

# atuin
command -v atuin &>/dev/null && eval "$(atuin init zsh)"

# mcfly
command -v mcfly &>/dev/null && eval "$(mcfly init zsh)"

# gitleaks
[[ -f "$XDG_CONFIG_HOME/gitleaks/env.zsh" ]] && source "$XDG_CONFIG_HOME/gitleaks/env.zsh"

# 1Password
# [[ -f "$XDG_CONFIG_HOME/op/plugins.sh" ]] && source "$XDG_CONFIG_HOME/op/plugins.sh"

# ------------------------------------------------------------------------------
# ローカル設定
# ------------------------------------------------------------------------------
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"