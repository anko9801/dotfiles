# Kanata - Cross-platform key remapper for NixOS
# https://github.com/jtroo/kanata
# Uses NixOS built-in services.kanata module
# Note: Does NOT work on WSL (no access to input devices)
{
  lib,
  config,
  ...
}:

let
  # Only enable on NixOS desktop (not WSL)
  isDesktop = !(config.wsl.enable or false);
  kanataConfig = import ../../home/tools/kanata-config.nix;
in
{
  config = lib.mkIf isDesktop {
    services.kanata = {
      enable = true;
      keyboards.default = {
        # Empty list = auto-detect all keyboards
        devices = [ ];
        config = kanataConfig;
      };
    };
  };
}
