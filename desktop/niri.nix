{ pkgs, ... }:

{
  home.packages = with pkgs; [
    niri
    xwayland-satellite # XWayland support
    wl-clipboard
    cliphist # Clipboard history
    swww # Wallpaper
    brightnessctl
    playerctl
    pamixer
    grim # Screenshot
    slurp # Region selection
    satty # Screenshot annotation
  ];

  xdg.configFile."niri/config.kdl".source = ./niri/config.kdl;
}
