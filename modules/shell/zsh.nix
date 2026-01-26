{
  config,
  pkgs,
  lib,
  ...
}:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;

    # Shell aliases (replacing zsh-abbr - simpler and faster)
    shellAliases = {
      # Safety and utility
      rm = "gomi";
      cp = "cp -i";
      mv = "mv -i";
      mkdir = "mkdir -p";

      # Modern CLI replacements
      ls = "eza";
      ll = "eza -l";
      la = "eza -la";
      lt = "eza --tree";
      lta = "eza --tree -a";
      cat = "bat";
      find = "fd";
      grep = "rg";
      top = "btm";
      htop = "btm";
      du = "dust";
      ps = "procs";
      sed = "sd";
      df = "df -h";
      free = "free -h";

      # Navigation
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";
      dl = "cd ~/Downloads";
      dt = "cd ~/Desktop";
      pj = "cd ~/repos";
      dot = "cd ~/dotfiles";

      # Git (using git aliases)
      g = "git";
      gst = "git st";
      gsw = "git sw";
      gf = "git f";
      gpl = "git pl";
      gps = "git ps";
      glg = "git lg";
      gla = "git la";
      gdf = "git df";
      gstaged = "git staged";
      gamend = "git amend";
      gundo = "git undo";
      gunstage = "git unstage";
      gcleanup = "git cleanup";
      gopen = "git open";
      gc = "ghq get";

      # Docker
      d = "docker";
      dc = "docker-compose";
      dps = "docker ps";
      dpsa = "docker ps -a";
      di = "docker images";
      drm = "docker rm";
      drmi = "docker rmi";

      # Editors
      v = "vim";
      nv = "nvim";
      c = "code";

      # tmux
      t = "tmux";
      ta = "tmux attach";
      tn = "tmux new";
      tl = "tmux list-sessions";
      tk = "tmux kill-session";
      ts = "tmux switch";

      # Tools
      gu = "gitui";
      zj = "zellij";
      zja = "zellij attach";
      zjl = "zellij list-sessions";
      zjk = "zellij kill-session";

      # Development
      py = "python3";
      pip = "uv pip";
      venv = "uv venv";

      # GitHub CLI
      ghpr = "gh pr create";
      ghpv = "gh pr view";
      ghpl = "gh pr list";
      ghrc = "gh repo clone";
      ghrv = "gh repo view --web";

      # ghq
      gql = "ghq list";
      gqr = "ghq root";

      # Misc
      h = "history";
      j = "jobs";
      reload = "source ~/.zshrc";
    };

    # History configuration
    history = {
      size = 10000;
      save = 10000;
      path = "$HOME/.zhistory";
      extended = true;
      share = true;
      ignoreDups = true;
      ignoreAllDups = true;
      ignoreSpace = true;
    };

    # Shell options
    autocd = true;

    # Syntax highlighting
    syntaxHighlighting.enable = true;

    # Autosuggestions
    autosuggestion = {
      enable = true;
      strategy = [
        "history"
        "completion"
      ];
    };

    # Plugins from nixpkgs
    plugins = [
      {
        name = "fzf-tab";
        src = pkgs.zsh-fzf-tab;
        file = "share/fzf-tab/fzf-tab.plugin.zsh";
      }
    ];

    # Completion styles
    completionInit = ''
      autoload -Uz compinit
      compinit -C
    '';

    # Main initialization using initContent (new API)
    initContent = lib.mkMerge [
      # Early initialization
      (lib.mkBefore ''
        # GPG TTY
        export GPG_TTY=$(tty)
      '')

      # Main configuration
      ''
        # ==============================================================================
        # Shell Options
        # ==============================================================================
        # Directory navigation
        setopt AUTO_PUSHD
        setopt PUSHD_IGNORE_DUPS
        setopt PUSHD_SILENT

        # Completion
        setopt AUTO_MENU
        setopt AUTO_PARAM_SLASH
        setopt AUTO_PARAM_KEYS
        setopt COMPLETE_IN_WORD
        setopt ALWAYS_LAST_PROMPT
        setopt LIST_PACKED
        setopt LIST_TYPES
        setopt MARK_DIRS

        # Expansion and globbing
        setopt EXTENDED_GLOB
        setopt GLOBDOTS
        setopt MAGIC_EQUAL_SUBST

        # Input/Output
        setopt INTERACTIVE_COMMENTS
        setopt PRINT_EIGHT_BIT
        setopt NO_FLOW_CONTROL
        setopt CORRECT
        setopt NO_BEEP

        # Job control
        setopt LONG_LIST_JOBS
        setopt NOTIFY
        setopt NO_HUP

        # Safety
        setopt RM_STAR_SILENT

        # History (additional)
        setopt HIST_VERIFY
        setopt HIST_REDUCE_BLANKS

        # ==============================================================================
        # Completion Styles
        # ==============================================================================
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

        # Spell correction prompt
        SPROMPT="correct: %F{red}%R%f -> %F{green}%r%f ? [No/Yes/Abort/Edit]"

        # ==============================================================================
        # FZF-tab Configuration
        # ==============================================================================
        zstyle ':completion:*:git-checkout:*' sort false
        zstyle ':completion:*:descriptions' format '[%d]'
        zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
        zstyle ':fzf-tab:*' switch-group ',' '.'
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

        # Use tmux popup if available
        if [[ -n "$TMUX" ]]; then
            zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup
        fi

        # ==============================================================================
        # Custom Functions
        # ==============================================================================

        # ghq + fzf integration - quickly cd to repositories
        ghq-fzf() {
            local selected
            selected=$(ghq list | fzf --height=40% --layout=reverse --border --preview "cat $(ghq root)/{}/README.md 2>/dev/null || ls -la $(ghq root)/{}")
            if [[ -n "$selected" ]]; then
                cd "$(ghq root)/$selected" || return
            fi
        }
        alias gq='ghq-fzf'

        # ghq + fzf - open in editor
        ghq-code() {
            local selected
            selected=$(ghq list | fzf --height=40% --layout=reverse --border)
            if [[ -n "$selected" ]]; then
                code "$(ghq root)/$selected"
            fi
        }

        # Create new directory and cd into it
        mkcd() {
            mkdir -p "$1" && cd "$1" || return
        }

        # Extract various archive formats
        extract() {
            if [ -f "$1" ]; then
                case "$1" in
                    *.tar.bz2)   tar xjf "$1"   ;;
                    *.tar.gz)    tar xzf "$1"   ;;
                    *.bz2)       bunzip2 "$1"   ;;
                    *.rar)       unrar x "$1"   ;;
                    *.gz)        gunzip "$1"    ;;
                    *.tar)       tar xf "$1"    ;;
                    *.tbz2)      tar xjf "$1"   ;;
                    *.tgz)       tar xzf "$1"   ;;
                    *.zip)       unzip "$1"     ;;
                    *.Z)         uncompress "$1";;
                    *.7z)        7z x "$1"      ;;
                    *.xz)        xz -d "$1"     ;;
                    *.tar.xz)    tar xJf "$1"   ;;
                    *.zst)       zstd -d "$1"   ;;
                    *.tar.zst)   tar --zstd -xf "$1" ;;
                    *)           echo "'$1' cannot be extracted via extract()" ;;
                esac
            else
                echo "'$1' is not a valid file"
            fi
        }

        # fzf-powered cd
        fcd() {
            local dir
            dir=$(fd --type d --hidden --follow --exclude .git 2>/dev/null | fzf --height=40% --layout=reverse --border --preview 'eza --tree --level=2 --color=always {} | head -100') && cd "$dir" || return
        }

        # Kill process with fzf
        fkill() {
            local pid
            pid=$(ps aux | sed 1d | fzf --height=40% --layout=reverse --border --multi | awk '{print $2}')
            if [[ -n "$pid" ]]; then
                echo "$pid" | xargs kill -9
            fi
        }

        # Git branch switch with fzf
        fbr() {
            local branches branch
            branches=$(git branch --all | grep -v HEAD) &&
            branch=$(echo "$branches" | fzf --height=40% --layout=reverse --border -d $(( 2 + $(wc -l <<< "$branches") )) +m) &&
            git checkout "$(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##")"
        }

        # Docker container exec with fzf
        dexec() {
            local container
            container=$(docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}" | sed 1d | fzf --height=40% --layout=reverse --border | awk '{print $1}')
            if [[ -n "$container" ]]; then
                docker exec -it "$container" /bin/bash || docker exec -it "$container" /bin/sh
            fi
        }

        # Search history with fzf
        fh() {
            print -z $( ([ -n "$ZSH_NAME" ] && fc -l 1 || history) | fzf --height=40% --layout=reverse --border --tac | sed -E 's/ *[0-9]*\*? *//' | sed -E 's/\\/\\\\/g')
        }

        # Git log with fzf
        fgl() {
            git log --oneline --color=always | fzf --ansi --preview 'git show --color=always {1}' | awk '{print $1}'
        }

        # ==============================================================================
        # Tool Integrations
        # ==============================================================================
        # mcfly (if installed separately)
        command -v mcfly &>/dev/null && eval "$(mcfly init zsh)"

        # 1Password plugin integrations
        if command -v op &>/dev/null; then
            command -v gh &>/dev/null && alias gh='op plugin run -- gh'
            command -v aws &>/dev/null && alias aws='op plugin run -- aws'
            command -v gcloud &>/dev/null && alias gcloud='op plugin run -- gcloud'
            command -v az &>/dev/null && alias az='op plugin run -- az'
            command -v stripe &>/dev/null && alias stripe='op plugin run -- stripe'
        fi

        # ==============================================================================
        # Local Settings
        # ==============================================================================
        [[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
      ''
    ];
  };

  # Additional zsh plugins as packages
  home.packages = with pkgs; [
    zsh-fzf-tab
  ];
}
