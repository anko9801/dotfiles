{ pkgs, ... }:

{
  imports = [
    ../../home/tools
    ../../home/editor
    ../../home/desktop
  ];

  home = {
    sessionVariables = {
      MOZ_ENABLE_WAYLAND = "1";
      QT_QPA_PLATFORM = "wayland;xcb";
    };

    packages = with pkgs; [
      xdg-utils
      xclip
      wl-clipboard
    ];
  };
}
