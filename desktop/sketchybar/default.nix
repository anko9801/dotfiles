{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (pkgs.lua55Packages) lua;
  inherit (import ./native.nix { inherit pkgs; }) metrics;
in
{
  imports = [ ./itsycal.nix ];

  home-manager.users.${config.system.primaryUser} = {
    home.packages = [ lua ];

    launchd.agents.sketchybar-network = {
      enable = true;
      config = {
        Label = "org.dotfiles.sketchybar-network";
        ProgramArguments = [
          "${metrics}/bin/desktop-network"
          "--watch"
          "/opt/homebrew/bin/sketchybar"
        ];
        RunAtLoad = true;
        KeepAlive = true;
        ThrottleInterval = 30;
      };
    };

    home.file = import ./files.nix {
      inherit pkgs lib;
      inherit (config.home-manager.users.${config.system.primaryUser}.theme) colors;
    };
  };
}
