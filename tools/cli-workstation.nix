# Workstation-only CLI tools (fancy alternatives, dev tools, etc.)
{ pkgs, config, ... }:

let
  p = config.platform;
in
{
  home.packages =
    with pkgs;
    [
      # Fancy alternatives
      sd # sed alternative (simpler syntax)
      ast-grep # structural code search
      dust # du alternative (visual)
      duf # df alternative (visual)
      ouch # universal archive tool
      procs # ps alternative

      # Data processing
      jless # JSON viewer
      dasel # universal data selector
      dyff # YAML/JSON diff tool
      yq-go # YAML processor

      # Network extras
      xh # httpie alternative
      nmap # network scanner

      # Container tools
      dive # Docker image layer explorer
      lazydocker # Docker TUI

      # Load testing
      oha # HTTP load generator

      # Dev tools
      sqlite # embedded database
      watchexec # file watcher
      android-tools # adb, fastboot

      # Media
      ffmpeg

      # Document tools
      glow # terminal markdown renderer
      typst # modern LaTeX alternative

      # Search
      nix-search-tv # Fuzzy nixpkgs search TUI

      # Linters
      yamllint
      markdownlint-cli
    ]
    ++ lib.optionals (p.os == "linux" && p.environment == "native") [
      xdg-utils
      xclip
    ];

  programs = {
    bottom.enable = true;
    k9s.enable = true;
    tealdeer = {
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
  };
}
