# Workstation-only CLI tools (fancy alternatives, dev tools, etc.)
{ pkgs, config, ... }:

let
  p = config.platform;
in
{
  home.packages =
    with pkgs;
    [
      # keep-sorted start
      ast-grep
      bottom
      dasel
      dive
      duf
      dust
      dyff
      ffmpeg
      glow
      jless
      k9s
      lazydocker
      markdownlint-cli
      nix-search-tv
      nmap
      oha
      ouch
      procs
      sd
      sqlite
      typst
      watchexec
      xh
      yamllint
      yq-go
      # keep-sorted end
    ]
    ++ lib.optionals (p.os == "linux" && p.environment == "native") [
      xdg-utils
      xclip
    ];

  programs.tealdeer = {
    enable = true;
    settings = {
      display = {
        compact = false;
        use_pager = true;
      };
      updates = {
        auto_update = true;
        auto_update_interval_hours = 720;
      };
    };
  };
}
