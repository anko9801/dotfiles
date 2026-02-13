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
      bottom # btm: top/htop alternative
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
      k9s # Kubernetes TUI

      # Load testing
      oha # HTTP load generator

      # Dev tools
      sqlite # embedded database
      watchexec # file watcher

      # Document tools
      glow # terminal markdown renderer
      typst # modern LaTeX alternative

      # Linters
      yamllint
      markdownlint-cli
    ]
    ++ lib.optionals (p.os == "linux" && p.environment == "native") [
      xdg-utils
      xclip
      wl-clipboard
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
