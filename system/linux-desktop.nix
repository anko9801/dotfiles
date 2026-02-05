{ pkgs, ... }:

let
  isCI = builtins.getEnv "CI" != "";
in
{
  imports = [
    ../home/tools
    ../home/editor
  ];

  # CI環境ではsystemdユーザーサービスを起動しない
  systemd.user.startServices = if isCI then false else "sd-switch";

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
