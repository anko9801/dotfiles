# Stylix: unified theming across all tools
# Fonts, cursor, opacity — Stylix auto-applies to terminals, editors, etc.
{ pkgs, ... }:
{
  stylix = {
    enable = true;

    # Base16 color scheme
    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";

    # Wallpaper (required by Stylix, generated from base color)
    image = pkgs.runCommand "wallpaper.png" { buildInputs = [ pkgs.imagemagick ]; } ''
      magick -size 1920x1080 xc:#1e1e2e PNG32:$out
    '';

    # Fonts
    fonts = {
      monospace = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrainsMono Nerd Font";
      };
      sansSerif = {
        package = pkgs.noto-fonts;
        name = "Noto Sans";
      };
      serif = {
        package = pkgs.noto-fonts;
        name = "Noto Serif";
      };
      emoji = {
        package = pkgs.noto-fonts-color-emoji;
        name = "Noto Color Emoji";
      };
      sizes = {
        terminal = 14;
        applications = 12;
      };
    };

    # Opacity
    opacity = {
      terminal = 0.95;
      applications = 1.0;
    };

    # Cursor
    cursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Classic";
      size = 24;
    };
  };
}
