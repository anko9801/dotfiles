{
  pkgs,
  lib,
  config,
  unfree-pkgs,
  ...
}:

let
  unfreePkgs = unfree-pkgs;
in
{
  imports = [
    ./aliases.nix
    ./functions.nix
  ];

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    dotDir = "${config.xdg.configHome}/zsh"; # XDG compliant (HM 26.05+)

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
      ignorePatterns = [
        "ls *"
        "cd *"
        "pwd"
        "exit"
        "clear"
        "history *"
        "fg"
        "bg"
        "jobs"
      ];
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
      {
        name = "zsh-abbr";
        src = unfreePkgs.zsh-abbr;
        file = "share/zsh/zsh-abbr/zsh-abbr.plugin.zsh";
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

        # Auto-start zellij (if not already in zellij and interactive)
        if [[ -z "$ZELLIJ" && -z "$INSIDE_EMACS" && -z "$VSCODE_TERMINAL" ]] && command -v zellij &>/dev/null; then
          zellij attach -c
        fi

        # fzf-git-sh: Git + fzf keybindings (Ctrl-G Ctrl-F/B/T/H/R/S)
        if [[ -f "${pkgs.fzf-git-sh}/share/fzf-git-sh/fzf-git.sh" ]]; then
          source "${pkgs.fzf-git-sh}/share/fzf-git-sh/fzf-git.sh"
        fi
      '')

      # Shell options and completion styles
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

        # Use zellij popup if available (instead of tmux)
        if [[ -n "$ZELLIJ" ]]; then
            # zellij doesn't have popup yet, use default
            :
        elif [[ -n "$TMUX" ]]; then
            zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup
        fi
      ''

      # Local settings (loaded last)
      (lib.mkAfter ''
        # ==============================================================================
        # Local Settings
        # ==============================================================================
        [[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
      '')
    ];
  };
}
