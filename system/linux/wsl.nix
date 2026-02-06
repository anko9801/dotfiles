{
  pkgs,
  lib,
  ...
}:

{
  imports = [
    ../../home/terminal/zellij
  ];

  targets.genericLinux.enable = true;

  home = {
    file = {
      # Docker CLI plugins (for Docker Desktop integration)
      ".docker/cli-plugins/docker-buildx".source = "${pkgs.docker-buildx}/bin/docker-buildx";
      ".docker/cli-plugins/docker-compose".source = "${pkgs.docker-compose}/bin/docker-compose";
    };

    sessionVariables = {
      DISPLAY = ":0";
      WSL_INTEROP = "/run/WSL/1_interop";
      BROWSER = "xdg-open";
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
}
