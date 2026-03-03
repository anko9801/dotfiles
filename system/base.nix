# Home-manager plumbing and platform workarounds
{
  lib,
  pkgs,
  config,
  inputs,
  versions,
  ...
}:

let
  p = config.platform;
  nixglPkgs = inputs.nixgl.packages.${pkgs.system} or null;
in
{
  config = {
    targets.genericLinux.enable = p.os == "linux";

    targets.genericLinux.nixGL = lib.mkIf (p.os == "linux" && nixglPkgs != null) {
      packages = nixglPkgs;
      defaultWrapper = "mesa";
      installScripts = [ "mesa" ];
    };

    fonts.fontconfig.enable = p.os == "linux";

    defaults.browser = lib.mkIf (p.environment == "wsl") "xdg-open";

    home = {
      stateVersion = versions.home;
      preferXdgDirectories = true;

      file = lib.mkIf (p.environment == "wsl") {
        ".docker/cli-plugins/docker-buildx".source = "${pkgs.docker-buildx}/bin/docker-buildx";
        ".docker/cli-plugins/docker-compose".source = "${pkgs.docker-compose}/bin/docker-compose";
      };

      activation = lib.mkIf (p.environment == "wsl") {
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

    systemd.user.startServices = if p.environment == "ci" then false else "sd-switch";

    xdg.enable = true;

    programs = {
      home-manager.enable = true;
      bash.enable = lib.mkDefault true;
    };
  };
}
