{ lib, ... }:

{
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        # font managed by Stylix
        dpi-aware = lib.mkDefault "auto";
        prompt = lib.mkDefault "❯ ";
        terminal = lib.mkDefault "ghostty -e";
        layer = lib.mkDefault "overlay";
        width = lib.mkDefault 40;
        lines = lib.mkDefault 12;
        horizontal-pad = lib.mkDefault 20;
        vertical-pad = lib.mkDefault 12;
        inner-pad = lib.mkDefault 8;
      };
      # Colors managed by Stylix
      border = {
        width = lib.mkDefault 2;
        radius = lib.mkDefault 8;
      };
    };
  };
}
