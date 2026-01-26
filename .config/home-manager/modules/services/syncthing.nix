{ config, pkgs, lib, ... }:

{
  # Syncthing - file synchronization
  # Note: Only enable on non-WSL Linux (WSL should use Windows Syncthing)
  services.syncthing = lib.mkIf (!config.targets.genericLinux.enable or false) {
    enable = true;

    # Sync configuration
    tray = {
      enable = false;  # No tray on headless
    };
  };

  # For WSL/all platforms: just install the package for manual use
  home.packages = with pkgs; [
    syncthing
  ];
}
