{
  pkgs,
  lib,
  config,
  ...
}:

let
  sshExe = "/mnt/c/Windows/System32/OpenSSH/ssh.exe";
in
{
  options.programs.wsl.windowsUser = lib.mkOption {
    type = lib.types.str;
    description = "Windows username for WSL integration paths";
  };

  config = {
    targets.genericLinux.enable = true;

    # 1Password paths for WSL (uses Windows ssh.exe directly)
    tools.ssh = {
      onePasswordAgentPath = null; # Not needed - using Windows ssh.exe
      onePasswordSignProgram = "/mnt/c/Users/${config.programs.wsl.windowsUser}/AppData/Local/Microsoft/WindowsApps/op-ssh-sign-wsl.exe";
    };

    home = {
      sessionVariables = {
        DISPLAY = ":0";
        WSL_INTEROP = "/run/WSL/1_interop";
        BROWSER = "xdg-open";
        # Use Windows ssh.exe for Git operations (1Password SSH agent)
        GIT_SSH_COMMAND = sshExe;
      };

      packages = with pkgs; [
        wslu
      ];

      activation = {
        setupXdgOpen = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          if [[ -f /proc/sys/fs/binfmt_misc/WSLInterop ]]; then
            $DRY_RUN_CMD mkdir -p $HOME/.local/share/applications
            cat > $HOME/.local/share/applications/wslview.desktop << 'DESKTOP'
          [Desktop Entry]
          Type=Application
          Version=1.0
          Name=WSL Browser
          NoDisplay=true
          Exec=wslview %u
          MimeType=x-scheme-handler/http;x-scheme-handler/https;
          DESKTOP
            $DRY_RUN_CMD xdg-settings set default-web-browser wslview.desktop 2>/dev/null || true
          fi
        '';
      };
    };

    programs = {
      # SSH config - use Windows ssh.exe for 1Password integration
      ssh.extraConfig = ''
        # For hosts that need 1Password SSH agent, use Windows ssh.exe via ProxyCommand
        # Example:
        # Host github.com
        #   ProxyCommand ${sshExe} -W %h:%p %r@%h
      '';

      git.settings = {
        credential.helper = "/mnt/c/Program\\ Files/Git/mingw64/bin/git-credential-manager.exe";
        gpg.ssh.program = config.tools.ssh.onePasswordSignProgram;
        core.sshCommand = sshExe;
      };

      zsh.initContent = lib.mkAfter ''
        # WSL-Specific Configuration
        export WSL_HOST=$(tail -1 /etc/resolv.conf | cut -d' ' -f2 2>/dev/null || echo "localhost")

        # Windows paths
        export PATH="$PATH:/mnt/c/Windows/System32:/mnt/c/Windows/System32/WindowsPowerShell/v1.0"

        # Linux package managers
        [[ -d "/snap/bin" ]] && export PATH="/snap/bin:$PATH"
        [[ -d "/var/lib/flatpak/exports/bin" ]] && export PATH="/var/lib/flatpak/exports/bin:$PATH"

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

        alias pbcopy='clip.exe'
        alias pbpaste='powershell.exe -command "Get-Clipboard" | tr -d "\r"'

        # SSH wrapper to use Windows ssh.exe with 1Password
        ssh() {
          ${sshExe} "$@"
        }

        # X11 display (VcXsrv/Xming)
        (command -v vcxsrv.exe &>/dev/null || command -v xming.exe &>/dev/null) && export DISPLAY="''${WSL_HOST}:0"
      '';
    };
  };
}
