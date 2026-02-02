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
    settings = nixSettings;
    gc = {
      automatic = true;
      options = "--delete-older-than 7d";
    };
  };

  programs = {
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    nix-index = {
      enable = true;
      enableZshIntegration = true;
    };
    nix-index-database.comma.enable = true;
  };
}
