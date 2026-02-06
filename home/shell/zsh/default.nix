# Zsh configuration with deferred initialization for fast startup
#
# Initialization order:
# 1. EARLY (mkBefore) - Cannot defer, must run immediately:
#    - Zellij auto-attach (must happen before shell is ready)
#    - zsh-defer plugin load (other defers depend on it)
#    - Starship prompt (breaks in zellij if deferred)
#
# 2. DEFERRED (_init_deferred) - Runs after prompt via zsh-defer:
#    - GPG_TTY, compinit, fzf, direnv, zoxide, atuin
#
# 3. DEFERRED PLUGINS - Loaded via zsh-defer:
#    - fzf-tab, autosuggestions, fast-syntax-highlighting, zsh-abbr
#
# 4. PLATFORM-SPECIFIC (mkAfter) - Linux, WSL, macOS paths
#
# 5. LOCAL OVERRIDES - ~/.zshrc.local for machine-specific config
{
  pkgs,
  lib,
  config,
  unfreePkgs,
  ...
}:

let
  inherit (config.platform) isDarwin isLinux isWSL;
  fzfFlags = config.shell.fzf.defaultFlags;

  # External scripts (proper syntax highlighting, no Nix escaping needed)
  scripts = {
    abbr = builtins.readFile ./abbr.zsh;
    completion = builtins.readFile ./completion.zsh;
    functions = builtins.replaceStrings [ "@FZF_FLAGS@" ] [ fzfFlags ] (
      builtins.readFile ./functions.zsh
    );
    obsidian = builtins.readFile ./obsidian.zsh;
  };
in
{

  programs.zsh = {
    enable = true;
    dotDir = "${config.xdg.configHome}/zsh"; # XDG compliant (HM 26.05+)

    # History configuration (size from shell.historySize)
    history = {
      size = config.shell.historySize;
      save = config.shell.historySize;
      path = "$HOME/.zhistory";
      extended = true;
      share = true;
      ignoreDups = true;
      ignoreAllDups = true;
      ignoreSpace = true;
      ignorePatterns = map (p: "${p} *") config.shell.historyIgnorePatterns;
    };

    # Shell options
    autocd = true;

    # Syntax highlighting - using fast-syntax-highlighting (much faster than zsh-syntax-highlighting)
    syntaxHighlighting.enable = false;

    # Autosuggestions - deferred for faster startup
    autosuggestion.enable = false;

    # Plugins loaded via zsh-defer in initContent for faster startup
    plugins = [ ];

    # Completion: defer compinit for instant prompt
    enableCompletion = false;
    completionInit = "";

    # Main initialization using initContent (new API)
    initContent = lib.mkMerge [
      # Early initialization
      (lib.mkBefore ''
        # Auto-start zellij (CANNOT DEFER: must attach before shell is ready)
        if [[ -z "$ZELLIJ" && -z "$INSIDE_EMACS" && -z "$VSCODE_TERMINAL" && -z "$CI" && -t 0 ]] && command -v zellij &>/dev/null; then
          zellij attach -c
        fi

        # zsh-defer: deferred execution for faster startup (CANNOT DEFER: other defers depend on it)
        source ${pkgs.zsh-defer}/share/zsh-defer/zsh-defer.plugin.zsh

        # Starship (CANNOT DEFER: breaks prompt display in zellij, causes visual glitches)
        [[ $TERM != "dumb" ]] && eval "$(${pkgs.starship}/bin/starship init zsh)"

        # Deferred initializer (single function to minimize zsh-defer overhead)
        _init_deferred() {
          export GPG_TTY=$(tty)
          autoload -Uz compinit && compinit -C
          source <(${pkgs.fzf}/bin/fzf --zsh)
          eval "$(${pkgs.direnv}/bin/direnv hook zsh)"
          eval "$(${pkgs.zoxide}/bin/zoxide init zsh --cmd cd)"
          [[ $options[zle] = on ]] && eval "$(${pkgs.atuin}/bin/atuin init zsh)"
        }
        zsh-defer _init_deferred
        zsh-defer source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh
        zsh-defer source ${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh
        zsh-defer source ${pkgs.zsh-fast-syntax-highlighting}/share/zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh
        zsh-defer source ${unfreePkgs.zsh-abbr}/share/zsh/zsh-abbr/zsh-abbr.plugin.zsh
      '')

      # Shell options (all deferred)
      ''
        # Deferred shell options
        _init_shell_options() {
          # Directory stack for `cd -N` navigation
          setopt AUTO_PUSHD PUSHD_IGNORE_DUPS PUSHD_SILENT

          # Tab completion behavior
          setopt AUTO_MENU AUTO_PARAM_SLASH AUTO_PARAM_KEYS
          setopt COMPLETE_IN_WORD ALWAYS_LAST_PROMPT
          setopt LIST_PACKED LIST_TYPES MARK_DIRS

          # Glob patterns: ** recursive, .* hidden files
          setopt EXTENDED_GLOB GLOBDOTS MAGIC_EQUAL_SUBST

          # UX improvements
          setopt INTERACTIVE_COMMENTS PRINT_EIGHT_BIT
          setopt NO_FLOW_CONTROL CORRECT NO_BEEP

          # Background jobs
          setopt LONG_LIST_JOBS NOTIFY NO_HUP

          # History
          setopt HIST_VERIFY HIST_REDUCE_BLANKS
          setopt RM_STAR_SILENT
        }
        zsh-defer _init_shell_options
      ''

      # External scripts
      scripts.functions
      scripts.completion
      scripts.abbr
      scripts.obsidian

      # Platform-specific: Linux package managers
      (lib.mkIf isLinux (
        lib.mkAfter ''
          # Linux package managers
          [[ -d "/snap/bin" ]] && export PATH="/snap/bin:$PATH"
          [[ -d "/var/lib/flatpak/exports/bin" ]] && export PATH="/var/lib/flatpak/exports/bin:$PATH"
        ''
      ))

      # Platform-specific: WSL
      (lib.mkIf isWSL (
        lib.mkAfter ''
          # WSL-Specific Configuration
          export WSL_HOST=$(tail -1 /etc/resolv.conf | cut -d' ' -f2 2>/dev/null || echo "localhost")

          # Remove Windows starship from PATH (use WSL version only)
          export PATH=$(echo "$PATH" | tr ':' '\n' | grep -v '/mnt/c/Program Files/starship' | tr '\n' ':' | sed 's/:$//')

          # Windows paths
          export PATH="$PATH:/mnt/c/Windows/System32:/mnt/c/Windows/System32/WindowsPowerShell/v1.0"

          # Docker
          [[ -S "/var/run/docker.sock" ]] && export DOCKER_HOST="unix:///var/run/docker.sock"

          # WSL utilities
          wsl2_fix_time() {
            echo "Syncing WSL2 time..."
            if command -v ntpdate &>/dev/null; then
              sudo ntpdate ntp.nict.jp || sudo ntpdate time.google.com
            elif command -v hwclock &>/dev/null; then
              sudo hwclock -s
            else
              echo "No time sync tool found"
              return 1
            fi
            echo "Time synced!"
          }

          wsl2_compact_memory() {
            echo "Compacting WSL2 memory..."
            echo 1 | sudo tee /proc/sys/vm/drop_caches >/dev/null
            echo "Memory compacted!"
          }

          explorer() { explorer.exe "''${1:-.}"; }

          # pbcopy uses OSC 52 (defined in functions.nix)
          alias pbpaste='powershell.exe -command "Get-Clipboard" | tr -d "\r" | sed "s/^\xEF\xBB\xBF//"'
          alias op='op.exe'

          # X11 display (VcXsrv/Xming)
          (command -v vcxsrv.exe &>/dev/null || command -v xming.exe &>/dev/null) && export DISPLAY="''${WSL_HOST}:0"
        ''
      ))

      # Platform-specific: macOS
      (lib.mkIf isDarwin (
        lib.mkAfter ''
          # macOS-Specific Configuration
          export HOMEBREW_NO_ANALYTICS=1
          export HOMEBREW_NO_AUTO_UPDATE=1
          # Prevent Homebrew from installing runtimes (use mise instead)
          export HOMEBREW_FORBIDDEN_FORMULAE="node python python3 pip npm pnpm yarn"

          # GNU tools from Homebrew
          export PATH="/opt/homebrew/opt/coreutils/libexec/gnubin:$PATH"
          export PATH="/opt/homebrew/opt/gnu-sed/libexec/gnubin:$PATH"
          export PATH="/opt/homebrew/opt/grep/libexec/gnubin:$PATH"

          # iTerm2 integration
          [[ -e "''${HOME}/.iterm2_shell_integration.zsh" ]] && source "''${HOME}/.iterm2_shell_integration.zsh"
        ''
      ))

      # Machine-specific overrides
      (lib.mkAfter ''
        [[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
      '')
    ];
  };
}
