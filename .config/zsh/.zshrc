# Common environment variables
export LANG=ja_JP.UTF-8
export EDITOR=vim
export VISUAL=vim
export PAGER=less
export LESSHISTFILE=-  # Don't save less history
export GPG_TTY=$(tty)

# Application XDG compliance
export VIMINIT='let $MYVIMRC="$XDG_CONFIG_HOME/vim/vimrc" | source $MYVIMRC'
export INPUTRC="$XDG_CONFIG_HOME/readline/inputrc"

# mise (tool version manager)
export MISE_GLOBAL_CONFIG_FILE="$HOME/.config/mise/config.toml"

# FZF configuration
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# Build PATH efficiently
path_components=("$HOME/.local/bin" "$HOME/downloads")
[[ -e $HOME/path ]] && path_components+=("$HOME/path")
export PATH="${(j.:.)path_components}:$PATH"

# Development paths
export GOPATH=$HOME/go
export PATH="$GOPATH/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/.npm-global/bin:$PATH"

# OS-specific environment
case "$(uname -s)" in
    Darwin)
        [[ -f $XDG_CONFIG_HOME/zsh/env-darwin.zsh ]] && source $XDG_CONFIG_HOME/zsh/env-darwin.zsh
        ;;
    Linux)
        [[ -f $XDG_CONFIG_HOME/zsh/env-linux.zsh ]] && source $XDG_CONFIG_HOME/zsh/env-linux.zsh
        ;;
esac

# History configuration
export HISTFILE=${HOME}/.zhistory
export HISTSIZE=10000
export SAVEHIST=10000
setopt hist_ignore_dups
setopt EXTENDED_HISTORY
setopt share_history
setopt hist_ignore_all_dups
setopt hist_ignore_space

# Shell options (grouped for efficiency)
setopt auto_param_slash mark_dirs list_types auto_menu auto_param_keys \
       interactive_comments magic_equal_subst complete_in_word \
       always_last_prompt print_eight_bit extended_glob globdots \
       list_packed correct

# Smart completion initialization
autoload -Uz compinit
if [[ -n $HOME/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

zstyle ':completion:*:default' menu select=2
zstyle ':completion:*' verbose yes
zstyle ':completion:*' completer _expand _complete _match _prefix _approximate _list _history
zstyle ':completion:*:messages' format '%F{yellow}%d%f'
zstyle ':completion:*:warnings' format '%F{red}No matches for:%f %F{yellow}%d%f'
zstyle ':completion:*:descriptions' format '%F{yellow}completing %B%d%b%f'
zstyle ':completion:*:corrections' format '%F{yellow}%B%d %f%F{red}(errors: %e)%b%f'
zstyle ':completion:*:options' description 'yes'
zstyle ':completion:*' group-name ''

export LS_COLORS='di=94:ln=35:so=32:pi=33:ex=31:bd=46;94:cd=43;94:su=41;30:sg=46;30:tw=42;30:ow=43;30'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# Prompt correction
SPROMPT="correct: %F{red}%R%f -> %F{green}%r%f ? [No/Yes/Abort/Edit]"

# Load VCS functions efficiently
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

# Antidote plugin manager
ANTIDOTE_HOME="${ZDOTDIR:-$HOME}/.antidote"
[[ -d $ANTIDOTE_HOME ]] || git clone --depth=1 https://github.com/mattmc3/antidote.git $ANTIDOTE_HOME

# Source antidote
source $ANTIDOTE_HOME/antidote.zsh

# Initialize plugins
zsh_plugins="${ZDOTDIR:-$HOME}/.zsh_plugins.txt"
if [[ ! ${zsh_plugins}.zsh -nt ${zsh_plugins} ]]; then
  (antidote bundle <${zsh_plugins} >|${zsh_plugins}.zsh)
fi
source ${zsh_plugins}.zsh


# External tool integrations (lazy loaded)
command -v mise &> /dev/null && eval "$(mise activate zsh)"
command -v starship &> /dev/null && eval "$(starship init zsh)"
command -v zoxide &> /dev/null && eval "$(zoxide init --cmd cd --hook pwd zsh)"

# Configure fzf-tab (after plugin loads)
# disable sort when completing `git checkout`
zstyle ':completion:*:git-checkout:*' sort false
# set descriptions format to enable group support  
zstyle ':completion:*:descriptions' format '[%d]'
# preview directory's content with eza when completing cd
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
# switch group using `,` and `.`
zstyle ':fzf-tab:*' switch-group ',' '.'

# Source configurations
[[ -f $XDG_CONFIG_HOME/zsh/abbr.zsh ]] && source $XDG_CONFIG_HOME/zsh/abbr.zsh
[[ -f $XDG_CONFIG_HOME/zsh/copilot.zsh ]] && source $XDG_CONFIG_HOME/zsh/copilot.zsh

# fzf configuration
if command -v fzf &>/dev/null; then
    # Set up fzf key bindings and fuzzy completion
    eval "$(fzf --zsh)" 2>/dev/null || true
fi

# WSL2 specific configurations
[[ -f $XDG_CONFIG_HOME/zsh/wsl2.zsh ]] && source $XDG_CONFIG_HOME/zsh/wsl2.zsh
