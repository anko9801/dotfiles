{
  imports = [
    ./niri.nix
    ./fuzzel.nix
    ./swaync.nix
    ./ime.nix
  ];

  # Wayland environment variables for desktop Linux
  home.sessionVariables = {
    MOZ_ENABLE_WAYLAND = "1";
    QT_QPA_PLATFORM = "wayland;xcb";
  };
}
