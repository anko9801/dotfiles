{
  pkgs,
  ...
}:

{
  programs.zsh.initContent = ''
    # Deferred completion styles (loaded after compinit)
    _init_completion_styles() {
    # Completion: fuzzy match, cache, show descriptions
    zstyle ':completion:*:default' menu select=2
    zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
    zstyle ':completion:*' list-colors ''${(s.:.)LS_COLORS}
    zstyle ':completion:*' use-cache true
    zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/zsh/zcompcache"
    zstyle ':completion:*' verbose yes
    zstyle ':completion:*' completer _expand _complete _match _prefix _approximate _list _history

    # Formatting
    zstyle ':completion:*:messages' format '%F{yellow}%d%f'
    zstyle ':completion:*:warnings' format '%F{red}No matches for:%f %F{yellow}%d%f'
    zstyle ':completion:*:descriptions' format '%F{yellow}completing %B%d%b%f'
    zstyle ':completion:*:corrections' format '%F{yellow}%B%d %f%F{red}(errors: %e)%b%f'
    zstyle ':completion:*:options' description 'yes'
    zstyle ':completion:*' group-name ""

    # Colors
    export LS_COLORS='di=94:ln=35:so=32:pi=33:ex=31:bd=46;94:cd=43;94:su=41;30:sg=46;30:tw=42;30:ow=43;30'

    # Kill command completion
    zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
    zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

    # Man pages
    zstyle ':completion:*:manuals' separate-sections true
    zstyle ':completion:*:manuals.(^1*)' insert-sections true

    # SSH/SCP/RSYNC
    zstyle ':completion:*:(scp|rsync):*' tag-order 'hosts:-host:host hosts:-domain:domain hosts:-ipaddr:ip\ address *'
    zstyle ':completion:*:(scp|rsync):*' group-order users files all-files hosts-domain hosts-host hosts-ipaddr
    zstyle ':completion:*:ssh:*' tag-order 'hosts:-host:host hosts:-domain:domain hosts:-ipaddr:ip\ address *'
    zstyle ':completion:*:ssh:*' group-order users hosts-domain hosts-host users hosts-ipaddr

    # Ignored patterns
    zstyle ':completion:*:functions' ignored-patterns '(_*|pre(cmd|exec))'
    zstyle ':completion:*:*:*:users' ignored-patterns '_*'

    SPROMPT="correct: %F{red}%R%f -> %F{green}%r%f ? [No/Yes/Abort/Edit]"

    # fzf-tab: fuzzy completion with live preview
    zstyle ':completion:*:git-checkout:*' sort false
    zstyle ':completion:*:descriptions' format '[%d]'
    zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
    zstyle ':fzf-tab:*' switch-group ',' '.'
    zstyle ':fzf-tab:*' prefix '''
    zstyle ':fzf-tab:*' fzf-flags --height=40% --layout=reverse --border --preview-window=right:50%:wrap

    # File preview
    zstyle ':fzf-tab:complete:*:*' fzf-preview '
        if [[ -d $realpath ]]; then
            eza -1 --color=always $realpath
        elif [[ -f $realpath ]]; then
            bat --color=always --style=numbers --line-range=:100 $realpath 2>/dev/null || cat $realpath
        else
            echo $realpath
        fi
    '

    # Process preview for kill command
    zstyle ':fzf-tab:complete:kill:argument-rest' fzf-preview 'ps aux | grep -v grep | grep "''${''${(@s: :)words[2]}[2]}"'

    # Git completion preview
    zstyle ':fzf-tab:complete:git-(add|diff|restore):*' fzf-preview 'git diff --color=always $realpath'
    zstyle ':fzf-tab:complete:git-log:*' fzf-preview 'git log --oneline --color=always $realpath'
    zstyle ':fzf-tab:complete:git-show:*' fzf-preview 'git show --color=always $realpath'

    # systemctl preview
    zstyle ':fzf-tab:complete:systemctl-*:*' fzf-preview 'SYSTEMD_COLORS=1 systemctl status $word'

    # Environment variable preview
    zstyle ':fzf-tab:complete:(-command-|-parameter-|-brace-parameter-|export|unset|expand):*' fzf-preview 'echo ''${(P)word}'

    # Man page preview
    zstyle ':fzf-tab:complete:man:*' fzf-preview 'man -P cat $word | head -100'

    # tldr preview (fallback to man)
    zstyle ':fzf-tab:complete:tldr:argument-1' fzf-preview 'tldr --color=always $word 2>/dev/null || man -P cat $word | head -100'

    # Git branch preview
    zstyle ':fzf-tab:complete:git-checkout:*' fzf-preview 'git log --oneline --graph --color=always $word -- 2>/dev/null | head -50'
    zstyle ':fzf-tab:complete:git-switch:*' fzf-preview 'git log --oneline --graph --color=always $word -- 2>/dev/null | head -50'
    zstyle ':fzf-tab:complete:git-branch:*' fzf-preview 'git log --oneline --graph --color=always $word -- 2>/dev/null | head -50'
    zstyle ':fzf-tab:complete:git-merge:*' fzf-preview 'git log --oneline --graph --color=always $word -- 2>/dev/null | head -50'
    zstyle ':fzf-tab:complete:git-rebase:*' fzf-preview 'git log --oneline --graph --color=always $word -- 2>/dev/null | head -50'

    # Git stash preview
    zstyle ':fzf-tab:complete:git-stash:*' fzf-preview 'git stash show -p $word --color=always 2>/dev/null'

    # Docker container preview
    zstyle ':fzf-tab:complete:docker-container-*:*' fzf-preview 'docker container inspect $word 2>/dev/null | jq -C ".[0] | {Id, Name, State, Config: {Image, Cmd}}"'
    zstyle ':fzf-tab:complete:docker-exec:*' fzf-preview 'docker container inspect $word 2>/dev/null | jq -C ".[0] | {Name, State, Config: {Image}}"'
    zstyle ':fzf-tab:complete:docker-logs:*' fzf-preview 'docker logs --tail 50 $word 2>/dev/null'

    # Docker image preview
    zstyle ':fzf-tab:complete:docker-image-*:*' fzf-preview 'docker image inspect $word 2>/dev/null | jq -C ".[0] | {Id, RepoTags, Size, Created}"'
    zstyle ':fzf-tab:complete:docker-run:*' fzf-preview 'docker image inspect $word 2>/dev/null | jq -C ".[0] | {RepoTags, Size, Config: {Cmd, Entrypoint}}"'

    # SSH host preview (from config)
    zstyle ':fzf-tab:complete:ssh:*' fzf-preview 'grep -A5 "Host $word" ~/.ssh/config 2>/dev/null || echo "No config for $word"'
    zstyle ':fzf-tab:complete:scp:*' fzf-preview 'grep -A5 "Host $word" ~/.ssh/config 2>/dev/null || echo "No config for $word"'

    # Nix preview
    zstyle ':fzf-tab:complete:nix-shell:*' fzf-preview 'nix-env -qa --description ".*$word.*" 2>/dev/null | head -20'
    zstyle ':fzf-tab:complete:nix-build:*' fzf-preview 'nix eval --raw ".#$word.meta.description" 2>/dev/null || echo "$word"'

    # make target preview
    zstyle ':fzf-tab:complete:make:*' fzf-preview 'make -n $word 2>/dev/null | head -20 || echo "Target: $word"'

    # npm/pnpm script preview
    zstyle ':fzf-tab:complete:(npm|pnpm)-run:*' fzf-preview 'jq -r ".scripts.\"$word\"" package.json 2>/dev/null || echo "$word"'

    # zoxide directory preview
    zstyle ':fzf-tab:complete:z:*' fzf-preview 'eza -1 --color=always $word 2>/dev/null || ls -1 $word'
    zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'eza -1 --color=always $realpath 2>/dev/null'

    # Tool-specific previews (kubectl, brew, cargo, pip, npm, go, mise, aws, terraform, just)
    zstyle ':fzf-tab:complete:kubectl-*:*' fzf-preview 'kubectl describe $word 2>/dev/null | head -50'
    zstyle ':fzf-tab:complete:kubectl:*' fzf-preview 'kubectl explain $word 2>/dev/null | head -30'
    zstyle ':fzf-tab:complete:brew-(install|info|upgrade|uninstall):*' fzf-preview 'brew info $word 2>/dev/null'
    zstyle ':fzf-tab:complete:brew-cask-*:*' fzf-preview 'brew info --cask $word 2>/dev/null'
    zstyle ':fzf-tab:complete:cargo-install:*' fzf-preview 'cargo search $word 2>/dev/null | head -10'
    zstyle ':fzf-tab:complete:cargo-add:*' fzf-preview 'cargo search $word 2>/dev/null | head -10'
    zstyle ':fzf-tab:complete:rustup-*:*' fzf-preview 'rustup show 2>/dev/null'
    zstyle ':fzf-tab:complete:pip-install:*' fzf-preview 'pip show $word 2>/dev/null || pip search $word 2>/dev/null | head -10'
    zstyle ':fzf-tab:complete:pip-show:*' fzf-preview 'pip show $word 2>/dev/null'
    zstyle ':fzf-tab:complete:pip-uninstall:*' fzf-preview 'pip show $word 2>/dev/null'
    zstyle ':fzf-tab:complete:uv-pip-*:*' fzf-preview 'pip show $word 2>/dev/null'
    zstyle ':fzf-tab:complete:python:*' fzf-preview 'file $realpath 2>/dev/null; head -20 $realpath 2>/dev/null'
    zstyle ':fzf-tab:complete:npm-install:*' fzf-preview 'npm view $word 2>/dev/null | head -20'
    zstyle ':fzf-tab:complete:pnpm-add:*' fzf-preview 'npm view $word 2>/dev/null | head -20'
    zstyle ':fzf-tab:complete:bun-add:*' fzf-preview 'npm view $word 2>/dev/null | head -20'
    zstyle ':fzf-tab:complete:node:*' fzf-preview 'file $realpath 2>/dev/null; head -20 $realpath 2>/dev/null'
    zstyle ':fzf-tab:complete:go-*:*' fzf-preview 'go doc $word 2>/dev/null | head -30'
    zstyle ':fzf-tab:complete:mise-install:*' fzf-preview 'mise ls-remote $word 2>/dev/null | tail -20'
    zstyle ':fzf-tab:complete:mise-use:*' fzf-preview 'mise ls-remote $word 2>/dev/null | tail -20'
    zstyle ':fzf-tab:complete:mise-*:*' fzf-preview 'mise info 2>/dev/null'
    zstyle ':fzf-tab:complete:aws:*' fzf-preview 'aws $word help 2>/dev/null | head -50'
    zstyle ':fzf-tab:complete:terraform-*:*' fzf-preview 'terraform providers schema -json 2>/dev/null | jq -C ".provider_schemas | keys" 2>/dev/null || echo "$word"'
    zstyle ':fzf-tab:complete:just:*' fzf-preview 'just --show $word 2>/dev/null || just --list 2>/dev/null'
    zstyle ':fzf-tab:complete:lazygit:*' fzf-preview 'git -C $realpath log --oneline -10 2>/dev/null || echo "$word"'

    # Archives
    zstyle ':fzf-tab:complete:tar-*:*' fzf-preview 'tar -tvf $realpath 2>/dev/null | head -50'
    zstyle ':fzf-tab:complete:unzip:*' fzf-preview 'unzip -l $realpath 2>/dev/null | head -50'
    zstyle ':fzf-tab:complete:7z:*' fzf-preview '7z l $realpath 2>/dev/null | head -50'
    zstyle ':fzf-tab:complete:zstd:*' fzf-preview 'zstd -l $realpath 2>/dev/null'

    # File permissions
    zstyle ':fzf-tab:complete:chmod:*' fzf-preview 'stat $realpath 2>/dev/null; eza -la $realpath 2>/dev/null'
    zstyle ':fzf-tab:complete:chown:*' fzf-preview 'stat $realpath 2>/dev/null; eza -la $realpath 2>/dev/null'

    # Destructive commands: preview contents before deletion
    zstyle ':fzf-tab:complete:rm:*' fzf-preview '
        if [[ -d $realpath ]]; then
            eza --tree --level=2 --color=always $realpath 2>/dev/null | head -50
        else
            bat --color=always --style=numbers --line-range=:50 $realpath 2>/dev/null || head -50 $realpath
        fi
    '
    zstyle ':fzf-tab:complete:trash:*' fzf-preview '
        if [[ -d $realpath ]]; then
            eza --tree --level=2 --color=always $realpath 2>/dev/null | head -50
        else
            bat --color=always --style=numbers --line-range=:50 $realpath 2>/dev/null || head -50 $realpath
        fi
    '

    # Search and data tools
    zstyle ':fzf-tab:complete:rg:*' fzf-preview 'bat --color=always --style=numbers $realpath 2>/dev/null | head -100'
    zstyle ':fzf-tab:complete:fd:*' fzf-preview 'eza -la --color=always $realpath 2>/dev/null'
    zstyle ':fzf-tab:complete:jq:*' fzf-preview 'jq -C "." $realpath 2>/dev/null | head -50'
    zstyle ':fzf-tab:complete:yq:*' fzf-preview 'yq -C "." $realpath 2>/dev/null | head -50'

    # Editors
    zstyle ':fzf-tab:complete:(nvim|vim|vi|code):*' fzf-preview '
        if [[ -d $realpath ]]; then
            eza --tree --level=2 --color=always $realpath 2>/dev/null
        else
            bat --color=always --style=numbers --line-range=:100 $realpath 2>/dev/null || cat $realpath
        fi
    '

    # System tools
    zstyle ':fzf-tab:complete:gh:*' fzf-preview 'gh $word --help 2>/dev/null | head -30'
    zstyle ':fzf-tab:complete:journalctl:*' fzf-preview 'journalctl -u $word --no-pager -n 20 2>/dev/null'
    zstyle ':fzf-tab:complete:ps:*' fzf-preview 'ps aux | head -1; ps aux | grep $word | head -20'
    zstyle ':fzf-tab:complete:pkill:*' fzf-preview 'ps aux | grep $word | head -20'

    # tmux popup (zellij doesn't support popup yet)
    [[ -n "$TMUX" ]] && zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup
    }
    # Defer completion styles (runs after compinit and fzf-tab load)
    zsh-defer _init_completion_styles
  '';
}
