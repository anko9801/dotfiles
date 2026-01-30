{
  config,
  pkgs,
  lib,
  ...
}:

{
  # Syncthing - file synchronization
  # Note: Only enable on non-WSL Linux (WSL should use Windows Syncthing)
  services.syncthing = lib.mkIf (!(config.targets.genericLinux.enable or false)) {
    enable = true;
    tray.enable = false; # No tray on headless
  };

  # Install syncthing package for all platforms
  home.packages = [ pkgs.syncthing ];
}
