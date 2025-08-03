# ==============================================================================
# Zsh Configuration
# ==============================================================================

# ------------------------------------------------------------------------------
# 環境変数
# ------------------------------------------------------------------------------
# 基本設定
export LANG=ja_JP.UTF-8
export EDITOR=vim
export VISUAL=vim
export PAGER=less
export LESSHISTFILE=-  # less履歴を保存しない
export GPG_TTY=$(tty)

# XDG準拠
export VIMINIT='let $MYVIMRC="$XDG_CONFIG_HOME/vim/vimrc" | source $MYVIMRC'
export INPUTRC="$XDG_CONFIG_HOME/readline/inputrc"

# 開発関連
export GOPATH=$HOME/go
export MISE_GLOBAL_CONFIG_FILE="$HOME/.config/mise/config.toml"

# FZF設定
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# ------------------------------------------------------------------------------
# PATH設定
# ------------------------------------------------------------------------------
# 基本PATH
path_components=(
    "$HOME/.local/bin"
    "$HOME/downloads"
    "$GOPATH/bin"
    "$HOME/.cargo/bin"
    "$HOME/.npm-global/bin"
)
[[ -e $HOME/path ]] && path_components+=("$HOME/path")
export PATH="${(j.:.)path_components}:$PATH"

# OS固有の環境変数を読み込み
[[ -f $XDG_CONFIG_HOME/zsh/env.zsh ]] && source $XDG_CONFIG_HOME/zsh/env.zsh

# 略語定義
[[ -f $XDG_CONFIG_HOME/zsh/abbr.zsh ]] && source $XDG_CONFIG_HOME/zsh/abbr.zsh

# ------------------------------------------------------------------------------
# 履歴設定
# ------------------------------------------------------------------------------
export HISTFILE=${HOME}/.zhistory
export HISTSIZE=10000
export SAVEHIST=10000

setopt EXTENDED_HISTORY       # 履歴に実行時間を記録
setopt share_history          # 履歴をセッション間で共有
setopt hist_ignore_all_dups   # 重複する履歴を記録しない
setopt hist_ignore_space      # スペースで始まるコマンドを記録しない

# ------------------------------------------------------------------------------
# シェルオプション
# ------------------------------------------------------------------------------
setopt auto_param_slash       # ディレクトリ名の補完で末尾に/を付ける
setopt mark_dirs              # ディレクトリにマッチした場合末尾に/を付ける
setopt list_types             # 補完候補にファイル種別を表示
setopt auto_menu              # 補完キー連打で順に補完候補を表示
setopt auto_param_keys        # カッコの対応などを自動的に補完
setopt interactive_comments   # コマンドラインでも#以降をコメントと見なす
setopt magic_equal_subst      # コマンドラインの引数で=以降も補完
setopt complete_in_word       # 語の途中でもカーソル位置で補完
setopt always_last_prompt     # カーソル位置は保持したままファイル名一覧を順次表示
setopt print_eight_bit        # 日本語ファイル名等を表示可能に
setopt extended_glob          # 拡張グロブで補完
setopt globdots               # 明確なドットの指定なしで.から始まるファイルをマッチ
setopt list_packed            # 補完候補を詰めて表示
setopt correct                # コマンドのスペルを訂正

# ------------------------------------------------------------------------------
# 補完設定
# ------------------------------------------------------------------------------
# 補完機能の初期化
autoload -Uz compinit
if [[ -n $HOME/.zcompdump(#qN.mh+24) ]]; then
    compinit
else
    compinit -C
fi

# 補完スタイル
zstyle ':completion:*:default' menu select=2
zstyle ':completion:*' verbose yes
zstyle ':completion:*' completer _expand _complete _match _prefix _approximate _list _history
zstyle ':completion:*:messages' format '%F{yellow}%d%f'
zstyle ':completion:*:warnings' format '%F{red}No matches for:%f %F{yellow}%d%f'
zstyle ':completion:*:descriptions' format '%F{yellow}completing %B%d%b%f'
zstyle ':completion:*:corrections' format '%F{yellow}%B%d %f%F{red}(errors: %e)%b%f'
zstyle ':completion:*:options' description 'yes'
zstyle ':completion:*' group-name ''

# LS_COLORS
export LS_COLORS='di=94:ln=35:so=32:pi=33:ex=31:bd=46;94:cd=43;94:su=41;30:sg=46;30:tw=42;30:ow=43;30'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# スペル訂正プロンプト
SPROMPT="correct: %F{red}%R%f -> %F{green}%r%f ? [No/Yes/Abort/Edit]"

# ------------------------------------------------------------------------------
# VCS情報（Git表示）
# ------------------------------------------------------------------------------
autoload -Uz add-zsh-hook vcs_info is-at-least

zstyle ":vcs_info:*" enable git svn hg bzr
zstyle ":vcs_info:*" formats "(%s)-[%b]"
zstyle ":vcs_info:*" actionformats "(%s)-[%b|%a]"
zstyle ":vcs_info:(svn|bzr):*" branchformat "%b:r%r"
zstyle ":vcs_info:bzr:*" use-simple true
zstyle ":vcs_info:*" max-exports 6

if is-at-least 4.3.10; then
    zstyle ":vcs_info:git:*" check-for-changes true
    zstyle ":vcs_info:git:*" stagedstr "<S>"
    zstyle ":vcs_info:git:*" unstagedstr "<U>"
    zstyle ":vcs_info:git:*" formats "(%b) %c%u"
    zstyle ":vcs_info:git:*" actionformats "(%s)-[%b|%a] %c%u"
fi

function _update_vcs_info_msg() {
    psvar=()
    LANG=en_US.UTF-8 vcs_info
    [[ -n "$vcs_info_msg_0_" ]] && psvar[1]="$vcs_info_msg_0_"
}

RPROMPT="[%F{blue}%~%f%1(v|%F{green}%1v%f|)]"
add-zsh-hook precmd _update_vcs_info_msg

# ------------------------------------------------------------------------------
# プラグインマネージャー (Antidote)
# ------------------------------------------------------------------------------
ANTIDOTE_HOME="${ZDOTDIR:-$HOME}/.antidote"
[[ -d $ANTIDOTE_HOME ]] || git clone --depth=1 https://github.com/mattmc3/antidote.git $ANTIDOTE_HOME

source $ANTIDOTE_HOME/antidote.zsh

# プラグインの読み込み
zsh_plugins="${ZDOTDIR:-$HOME}/.zsh_plugins.txt"
if [[ ! ${zsh_plugins}.zsh -nt ${zsh_plugins} ]]; then
    (antidote bundle <${zsh_plugins} >|${zsh_plugins}.zsh)
fi
source ${zsh_plugins}.zsh

# ------------------------------------------------------------------------------
# ツール統合
# ------------------------------------------------------------------------------
# mise（ツールバージョン管理）
command -v mise &> /dev/null && eval "$(mise activate zsh)"

# starship（プロンプト）
command -v starship &> /dev/null && eval "$(starship init zsh)"

# zoxide（スマートcd）
command -v zoxide &> /dev/null && eval "$(zoxide init --cmd cd --hook pwd zsh)"

# fzf（ファジー検索）
command -v fzf &> /dev/null && eval "$(fzf --zsh)"

# ------------------------------------------------------------------------------
# プラグイン設定
# ------------------------------------------------------------------------------
# fzf-tab設定（プラグイン読み込み後）
zstyle ':completion:*:git-checkout:*' sort false
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
zstyle ':fzf-tab:*' switch-group ',' '.'

