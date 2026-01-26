{
  config,
  pkgs,
  lib,
  ...
}:

{
  # Mark this as a generic Linux target (includes WSL)
  # This disables programs that don't work well on WSL (like VSCode)
  targets.genericLinux.enable = true;

  # WSL-specific configuration
  home.homeDirectory = lib.mkDefault "/home/anko";

  home.sessionVariables = {
    # WSL display settings
    DISPLAY = ":0";

    # WSL interop
    WSL_INTEROP = "/run/WSL/1_interop";

    # Browser (use Windows browser via xdg-open wrapper)
    BROWSER = "xdg-open";

    # 1Password SSH Agent (WSL path)
    SSH_AUTH_SOCK = "$HOME/.1password/agent.sock";
  };

  # WSL-specific packages
  home.packages = with pkgs; [
    wslu # WSL utilities (wslview, etc.)
    socat # For 1Password SSH agent forwarding
  ];

  # SSH configuration for WSL (1Password agent)
  programs.ssh.extraConfig = ''
    IdentityAgent ~/.1password/agent.sock
  '';

  # Git SSH signing program for WSL (1Password)
  programs.git.settings = {
    gpg.ssh.program = "/mnt/c/Users/anko/AppData/Local/1Password/app/8/op-ssh-sign-wsl";
    credential.helper = "/mnt/c/Program\\ Files/Git/mingw64/bin/git-credential-manager.exe";
  };

  # WSL activation scripts
  home.activation = {
    # Create 1Password SSH agent socket directory
    create1PasswordSocket = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      $DRY_RUN_CMD mkdir -p $HOME/.1password
    '';

    # Setup xdg-open to use Windows browser
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

  # WSL-specific zsh configuration
  programs.zsh.initContent = lib.mkAfter ''
    # ==============================================================================
    # WSL-Specific Configuration
    # ==============================================================================

    # WSL host IP
    export WSL_HOST=$(tail -1 /etc/resolv.conf | cut -d' ' -f2 2>/dev/null || echo "localhost")

    # Windows paths
    export PATH="$PATH:/mnt/c/Windows/System32:/mnt/c/Windows/System32/WindowsPowerShell/v1.0"

    # Snap/Flatpak support
    [[ -d "/snap/bin" ]] && export PATH="/snap/bin:$PATH"
    [[ -d "/var/lib/flatpak/exports/bin" ]] && export PATH="/var/lib/flatpak/exports/bin:$PATH"

    # Docker Desktop integration
    if [[ -S "/var/run/docker.sock" ]]; then
        export DOCKER_HOST="unix:///var/run/docker.sock"
    fi

    # WSL2 time sync fix
    wsl2_fix_time() {
        echo "Syncing WSL2 time..."
        if command -v ntpdate &>/dev/null; then
            sudo ntpdate ntp.nict.jp || sudo ntpdate time.google.com
        elif command -v hwclock &>/dev/null; then
            sudo hwclock -s
        else
            echo "No time sync tool found (install ntpdate or util-linux)"
            return 1
        fi
        echo "Time synced!"
    }

    # WSL2 memory reclaim
    wsl2_compact_memory() {
        echo "Compacting WSL2 memory..."
        echo 1 | sudo tee /proc/sys/vm/drop_caches >/dev/null
        echo "Memory compacted!"
    }

    # Open Windows Explorer from current directory
    explorer() {
        explorer.exe "''${1:-.}"
    }

    # Clipboard integration
    alias pbcopy='clip.exe'
    alias pbpaste='powershell.exe -command "Get-Clipboard" | tr -d "\r"'

    # X11 forwarding for GUI apps
    (command -v vcxsrv.exe &>/dev/null || command -v xming.exe &>/dev/null) && export DISPLAY="''${WSL_HOST}:0"
  '';
}
