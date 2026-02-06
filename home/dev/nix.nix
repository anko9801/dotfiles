{ pkgs, ... }:

let
  nixSettings = import ../../system/nix-settings.nix;
in
{
  home.packages = with pkgs; [
    nix-tree # Visualize nix store dependencies
    nix-du # Disk usage analyzer for nix store
    manix # Nix documentation search
    nix-diff # Compare nix derivations
    nvd # Nix version diff (compare closures)
    devenv # Development environments
    nixd # Nix LSP
    nixfmt # Formatter
    statix # Linter
  ];

  # nix.package is set in flake.nix for standalone home-manager only
  # (NixOS/darwin with useGlobalPkgs=true provides it from system)
  nix = {
    inherit (nixSettings) settings;
    gc = nixSettings.gc // {
      dates = nixSettings.gcSchedule.frequency;
    };
  };

  # Global devenv config
  xdg.configFile."devenv/config.yaml".text = ''
    # Global devenv configuration
    # https://devenv.sh/reference/yaml-options/

    # Disable telemetry
    disable_telemetry: true
  '';

  programs = {
    direnv = {
      enable = true;
      enableZshIntegration = false; # Deferred in zsh.nix for faster startup
      nix-direnv.enable = true;

      # Custom direnvrc for devenv auto-detection
      stdlib = ''
        # Auto-detect and use devenv when devenv.nix exists
        use_devenv() {
          watch_file devenv.nix devenv.lock devenv.yaml .devenv.flake.nix
          if has devenv; then
            eval "$(devenv print-dev-env)"
          fi
        }

        # Auto-use devenv if devenv.nix exists and .envrc doesn't exist or is empty
        layout_devenv() {
          use_devenv
        }
      '';
    };
    nix-index = {
      enable = true;
      enableZshIntegration = false; # Handled by nix-index-database flake module
    };
    nix-index-database.comma.enable = true;
  };
}
