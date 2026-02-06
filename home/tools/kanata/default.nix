# Kanata - Cross-platform key remapper
# https://github.com/jtroo/kanata
#
# Platform usage:
#   NixOS:   system/nixos/kanata.nix (services.kanata with proper permissions)
#   macOS:   This module (symlinks config, run via launchd or manually)
#   Windows: Use config.kbd directly
#   WSL:     Not supported (no input device access)
{ config, ... }:

{
  xdg.configFile."kanata/kanata.kbd".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/home/tools/kanata/config.kbd";
}
