{ pkgs, ... }:

{
  stylix = {
    enable = true;

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

    # Opacity
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

    # Target overrides
    targets = {
      vscode.enable = false;
    };
  };

  # Additional fonts
  home.packages = [
    pkgs.nerd-fonts.symbols-only
    pkgs.nerd-fonts.jetbrains-mono
  ];
}
