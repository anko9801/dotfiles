{ pkgs, inputs, ... }:

{
  home.packages = with pkgs; [
    # keep-sorted start
    devenv
    manix
    nh
    nix-diff
    nix-du
    nix-inspect
    nix-output-monitor
    nix-tree
    nixd
    nixfmt
    nixpkgs-review
    nvd
    statix
    # keep-sorted end
  ];

  nix.registry.nixpkgs.flake = inputs.nixpkgs;

  xdg.configFile."devenv/config.yaml".text = ''
    # Global devenv configuration
    # https://devenv.sh/reference/yaml-options/

    # Disable telemetry
    disable_telemetry: true
  '';

  programs = {
    direnv = {
      enable = true;
      enableZshIntegration = false; # Deferred via zsh-defer (shell/zsh/deferred.nix)
      nix-direnv.enable = true;

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
