{ lib, ... }:

let
  xdgAssociations =
    type: program: list:
    builtins.listToAttrs (
      map (e: {
        name = "${type}/${e}";
        value = program;
      }) list
    );

  browser = "firefox.desktop";
  editor = "nvim.desktop";
  fileManager = "org.gnome.Nautilus.desktop";
  imageViewer = "org.gnome.Loupe.desktop";
  videoPlayer = "io.github.celluloid_player.Celluloid.desktop";
in
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

  # XDG MIME associations
  xdg.mimeApps = {
    enable = true;
    defaultApplications = lib.mkMerge [
      (xdgAssociations "text" editor [
        "plain"
        "markdown"
        "x-python"
        "x-shellscript"
        "x-csrc"
        "x-chdr"
        "css"
        "html"
        "xml"
        "json"
        "javascript"
        "x-rust"
        "x-go"
        "x-nix"
      ])
      (xdgAssociations "application" editor [
        "json"
        "x-yaml"
        "toml"
        "xml"
      ])
      (xdgAssociations "image" imageViewer [
        "png"
        "jpeg"
        "gif"
        "webp"
        "svg+xml"
        "bmp"
      ])
      (xdgAssociations "video" videoPlayer [
        "mp4"
        "webm"
        "x-matroska"
        "quicktime"
      ])
      {
        "x-scheme-handler/http" = browser;
        "x-scheme-handler/https" = browser;
        "x-scheme-handler/mailto" = browser;
        "application/pdf" = browser;
        "inode/directory" = fileManager;
      }
    ];
  };
}
