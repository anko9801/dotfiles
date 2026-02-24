{ lib, ... }:

{
  programs.wezterm = {
    enable = true;
    enableZshIntegration = true;
    extraConfig = lib.mkAfter (builtins.readFile ./config.lua);
  };
}
