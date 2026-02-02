{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Nix development tools
    nix-tree # Interactive dependency browser
    nix-du # Store space visualization
    manix # NixOS/HM option search
    nix-diff # Compare Nix derivations
    nvd # Nix version diff (compare closures)
    devenv # Per-project development environments

    # Nix LSP
    nixd

    # Nix linter & formatter
    nixfmt
    statix
  ];
}
