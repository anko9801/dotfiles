# Kanata - Cross-platform key remapper for NixOS
# https://github.com/jtroo/kanata
# Uses NixOS built-in services.kanata module
# Config shared with macOS/Windows: home/tools/kanata/config.kbd
{
  lib,
  config,
  ...
}:

let
  # Only enable on NixOS desktop (not WSL)
  isDesktop = !(config.wsl.enable or false);
  kanataConfig = builtins.readFile ../../home/tools/kanata/config.kbd;
in
{
  config = lib.mkIf isDesktop {
    services.kanata = {
      enable = true;
      keyboards.default = {
        devices = [ ]; # Empty = auto-detect all keyboards
        config = kanataConfig;
      };
    };
  };
}
