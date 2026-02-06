_:

{
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        # font managed by Stylix
        dpi-aware = "auto";
        prompt = "❯ ";
        terminal = "ghostty -e";
        layer = "overlay";
        width = 40;
        lines = 12;
        horizontal-pad = 20;
        vertical-pad = 12;
        inner-pad = 8;
      };
      # Colors managed by Stylix
      border = {
        width = 2;
        radius = 8;
      };
    };
  };
}
