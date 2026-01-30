{
  pkgs,
  lib,
  ...
}:

{
  imports = [
    ../tools/vim.nix
  ];

  targets.genericLinux.enable = true;

  xdg.configFile.wsl = {
    source = ../../configs/wsl;
    recursive = true;
  };

  home = {
    homeDirectory = lib.mkDefault "/home/anko";

    sessionVariables = {
      DISPLAY = ":0";
      WSL_INTEROP = "/run/WSL/1_interop";
      BROWSER = "xdg-open";
      SSH_AUTH_SOCK = "$HOME/.1password/agent.sock";
    };

    packages = with pkgs; [
      wslu
      socat # For 1Password SSH agent bridge
    ];

    activation = {
      create1PasswordSocketDir = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        $DRY_RUN_CMD mkdir -p $HOME/.1password
      '';

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
    git.settings = {
      credential.helper = "/mnt/c/Program\\ Files/Git/mingw64/bin/git-credential-manager.exe";
      gpg.ssh.program = "/mnt/c/Users/anko/AppData/Local/Microsoft/WindowsApps/op-ssh-sign-wsl.exe";
    };

    ssh.extraConfig = ''
      IdentityAgent ~/.1password/agent.sock
    '';

    zsh.initContent = lib.mkAfter ''
      # WSL-Specific Configuration

      export WSL_HOST=$(tail -1 /etc/resolv.conf | cut -d' ' -f2 2>/dev/null || echo "localhost")

      # 1Password SSH Agent bridge (Windows -> WSL)
      _1p_socket="$HOME/.1password/agent.sock"
      _1p_relay="/mnt/c/Users/anko/go/bin/npiperelay.exe"
      if [[ -x "$_1p_relay" ]] && ! pgrep -f "npiperelay.*openssh-ssh-agent" >/dev/null 2>&1; then
        rm -f "$_1p_socket"
        (setsid socat UNIX-LISTEN:"$_1p_socket",fork EXEC:"$_1p_relay -ei -s //./pipe/openssh-ssh-agent",nofork &) >/dev/null 2>&1
      fi
      unset _1p_socket _1p_relay
      export PATH="$PATH:/mnt/c/Windows/System32:/mnt/c/Windows/System32/WindowsPowerShell/v1.0"

      [[ -d "/snap/bin" ]] && export PATH="/snap/bin:$PATH"
      [[ -d "/var/lib/flatpak/exports/bin" ]] && export PATH="/var/lib/flatpak/exports/bin:$PATH"

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

      alias pbcopy='clip.exe'
      alias pbpaste='powershell.exe -command "Get-Clipboard" | tr -d "\r"'

      (command -v vcxsrv.exe &>/dev/null || command -v xming.exe &>/dev/null) && export DISPLAY="''${WSL_HOST}:0"
    '';
  };
}
