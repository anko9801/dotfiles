# Zsh configuration: history, options, scripts, and platform-specific settings
{
  lib,
  config,
  ...
}:

let
  p = config.platform;
  fzfFlags = config.shell.fzf.defaultFlags;

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
  imports = [ ./deferred.nix ];

  programs.zsh = {
    enable = true;
    dotDir = "${config.xdg.configHome}/zsh";

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

    autocd = true;

    initContent = lib.mkMerge [
      # mise shims for immediate tool availability
      (lib.mkBefore ''
        export PATH="$HOME/.local/share/mise/shims:$PATH"
      '')

      # Shell options (deferred)
      ''
        _init_shell_options() {
          # Directory Navigation
          setopt AUTO_PUSHD
          setopt PUSHD_IGNORE_DUPS
          setopt PUSHD_SILENT
          setopt PUSHD_TO_HOME

          # Completion
          setopt AUTO_MENU
          setopt AUTO_PARAM_SLASH
          setopt AUTO_PARAM_KEYS
          setopt AUTO_REMOVE_SLASH
          setopt COMPLETE_IN_WORD
          setopt ALWAYS_LAST_PROMPT
          setopt LIST_PACKED
          setopt LIST_TYPES
          setopt MARK_DIRS
          unsetopt MENU_COMPLETE

          # Globbing & Expansion
          setopt EXTENDED_GLOB
          setopt GLOBDOTS
          setopt MAGIC_EQUAL_SUBST
          setopt NUMERIC_GLOB_SORT
          setopt NONOMATCH

          # Input/Output
          setopt INTERACTIVE_COMMENTS
          setopt PRINT_EIGHT_BIT
          setopt NO_FLOW_CONTROL
          setopt NO_BEEP
          setopt MULTIOS
          setopt CORRECT
          alias mkdir='nocorrect mkdir'
          alias mv='nocorrect mv'
          alias cp='nocorrect cp'
          alias rm='nocorrect rm'
          alias sudo='nocorrect sudo'

          # Jobs & Background
          setopt LONG_LIST_JOBS
          setopt NOTIFY
          setopt NO_HUP

          # History
          setopt HIST_VERIFY
          setopt HIST_REDUCE_BLANKS
          setopt HIST_NO_STORE
          setopt HIST_EXPAND
          setopt HIST_NO_FUNCTIONS
          setopt HIST_ALLOW_CLOBBER

          # Safety
          setopt RM_STAR_SILENT
          setopt IGNORE_EOF
          unsetopt CLOBBER
        }
        zsh-defer _init_shell_options
      ''

      # External scripts
      scripts.functions
      scripts.completion
      scripts.abbr
      scripts.obsidian

      # Platform-specific: Linux package managers
      (lib.mkIf (p.os == "linux") (
        lib.mkAfter ''
          [[ -d "/snap/bin" ]] && export PATH="/snap/bin:$PATH"
          [[ -d "/var/lib/flatpak/exports/bin" ]] && export PATH="/var/lib/flatpak/exports/bin:$PATH"
        ''
      ))

      # Platform-specific: WSL
      (lib.mkIf (p.environment == "wsl") (
        lib.mkAfter ''
          export WSL_HOST=$(tail -1 /etc/resolv.conf | cut -d' ' -f2 2>/dev/null || echo "localhost")

          export PATH=$(echo "$PATH" | tr ':' '\n' | command grep -v '/mnt/c/Program Files/starship' | tr '\n' ':' | sed 's/:$//')
          export PATH="$PATH:/mnt/c/Windows/System32:/mnt/c/Windows/System32/WindowsPowerShell/v1.0"

          [[ -S "/var/run/docker.sock" ]] && export DOCKER_HOST="unix:///var/run/docker.sock"

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

          alias pbpaste='powershell.exe -command "Get-Clipboard" | tr -d "\r" | sed "s/^\xEF\xBB\xBF//"'
          alias op='op.exe'

          (command -v vcxsrv.exe &>/dev/null || command -v xming.exe &>/dev/null) && export DISPLAY="''${WSL_HOST}:0"
        ''
      ))

      # Platform-specific: macOS
      (lib.mkIf (p.os == "darwin") (
        lib.mkAfter ''
          export HOMEBREW_NO_AUTO_UPDATE=1
          export HOMEBREW_FORBIDDEN_FORMULAE="node python python3 pip npm pnpm yarn"

          export PATH="/opt/homebrew/opt/coreutils/libexec/gnubin:$PATH"
          export PATH="/opt/homebrew/opt/gnu-sed/libexec/gnubin:$PATH"
          export PATH="/opt/homebrew/opt/grep/libexec/gnubin:$PATH"

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
