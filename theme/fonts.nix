{ pkgs, ... }:

{
  stylix.fonts = {
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

  # Additional fonts (Nerd Font icons + JetBrains Mono as alternative)
  home.packages = [
    pkgs.nerd-fonts.symbols-only
    pkgs.nerd-fonts.jetbrains-mono
  ];
}
