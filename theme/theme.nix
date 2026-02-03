{
  pkgs,
  lib,
  ...
}:

{
  options.theme.colors = lib.mkOption {
    type = lib.types.attrsOf lib.types.str;
    default = {
      # Tokyo Night palette
      bg = "#1a1b26";
      bg_dark = "#16161e";
      bg_highlight = "#292e42";
      terminal_black = "#414868";
      fg = "#c0caf5";
      fg_dark = "#a9b1d6";
      fg_gutter = "#3b4261";
      dark3 = "#545c7e";
      comment = "#565f89";
      dark5 = "#737aa2";
      blue0 = "#3d59a1";
      blue = "#7aa2f7";
      cyan = "#7dcfff";
      blue1 = "#2ac3de";
      blue2 = "#0db9d7";
      blue5 = "#89ddff";
      blue6 = "#b4f9f8";
      blue7 = "#394b70";
      magenta = "#bb9af7";
      magenta2 = "#ff007c";
      purple = "#9d7cd8";
      orange = "#ff9e64";
      yellow = "#e0af68";
      green = "#9ece6a";
      green1 = "#73daca";
      green2 = "#41a6b5";
      teal = "#1abc9c";
      red = "#f7768e";
      red1 = "#db4b4b";
    };
    description = "Theme color palette for manual use in configs";
  };

  config = {
    # Stylix - Unified theming across all applications
    stylix = {
      enable = true;

      # Base16 color scheme - Tokyo Night
      base16Scheme = "${pkgs.base16-schemes}/share/themes/tokyo-night-dark.yaml";

      # Generate wallpaper from colors (or use an image)
      image = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/tokyo-night/tokyo-night-vscode-theme/master/static/ss_tokyo_night.png";
        sha256 = "sha256-FxBZyiOblkNNdeKcErll4Od2XYu4DvY/g+yz0sfHel8=";
      };

      # Fonts
      fonts = {
        monospace = {
          package = pkgs.nerd-fonts.jetbrains-mono;
          name = "JetBrainsMono Nerd Font";
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

    programs.dircolors = {
      enable = true;
      enableZshIntegration = true;
      extraConfig = ''
        DIR 01;34
        LINK 01;36
        EXEC 01;32
        .tar 01;31
        .gz 01;31
        .zip 01;31
        .7z 01;31
        .jpg 01;35
        .png 01;35
        .mp3 00;36
        .mp4 00;36
        .py 00;33
        .js 00;33
        .ts 00;33
        .rs 00;33
        .go 00;33
        .nix 00;33
      '';
    };
  };
}
