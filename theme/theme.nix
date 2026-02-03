{
  pkgs,
  lib,
  ...
}:

{
  options.theme.colors = lib.mkOption {
    type = lib.types.attrsOf lib.types.str;
    default = {
      # Catppuccin Mocha palette
      rosewater = "#f5e0dc";
      flamingo = "#f2cdcd";
      pink = "#f5c2e7";
      mauve = "#cba6f7";
      red = "#f38ba8";
      maroon = "#eba0ac";
      peach = "#fab387";
      yellow = "#f9e2af";
      green = "#a6e3a1";
      teal = "#94e2d5";
      sky = "#89dceb";
      sapphire = "#74c7ec";
      blue = "#89b4fa";
      lavender = "#b4befe";
      text = "#cdd6f4";
      subtext1 = "#bac2de";
      subtext0 = "#a6adc8";
      overlay2 = "#9399b2";
      overlay1 = "#7f849c";
      overlay0 = "#6c7086";
      surface2 = "#585b70";
      surface1 = "#45475a";
      surface0 = "#313244";
      base = "#1e1e2e";
      mantle = "#181825";
      crust = "#11111b";
    };
    description = "Theme color palette for manual use in configs";
  };

  config = {
    # Stylix - Unified theming across all applications
    stylix = {
      enable = true;

      # Base16 color scheme - Catppuccin Mocha
      base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";

      # Generate solid color wallpaper from base color
      image = pkgs.runCommand "wallpaper.png" { buildInputs = [ pkgs.imagemagick ]; } ''
        magick -size 1920x1080 xc:#1e1e2e PNG32:$out
      '';

      # Fonts
      fonts = {
        monospace = {
          package = pkgs.moralerspace;
          name = "Moralerspace Neon";
        };
        sansSerif = {
          package = pkgs.noto-fonts-cjk-sans;
          name = "Noto Sans CJK JP";
        };
        serif = {
          package = pkgs.noto-fonts-cjk-serif;
          name = "Noto Serif CJK JP";
        };
        emoji = {
          package = pkgs.noto-fonts-color-emoji;
          name = "Noto Color Emoji";
        };
        sizes = {
          terminal = 14;
          applications = 12;
          desktop = 12;
          popups = 12;
        };
      };

      # Opacity settings
      opacity = {
        terminal = 0.95;
        applications = 1.0;
        desktop = 1.0;
        popups = 0.95;
      };

      # Cursor
      cursor = {
        package = pkgs.bibata-cursors;
        name = "Bibata-Modern-Classic";
        size = 24;
      };

      # Target-specific overrides (most are auto-enabled)
      targets = {
        # Disable for apps with extensive custom config that would break
        vscode.enable = false; # Using Zed instead
      };
    };

    # Additional fonts (Nerd Font icons + JetBrains Mono as alternative)
    home.packages = [
      pkgs.nerd-fonts.symbols-only
      pkgs.nerd-fonts.jetbrains-mono
    ];
  };
}
