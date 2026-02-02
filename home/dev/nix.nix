{ pkgs, ... }:

{
  home.packages = with pkgs; [
    nix-tree # dependency browser
    nix-du # store space visualization
    manix # option search
    nix-diff # compare derivations
    nvd # compare closures
    devenv
    nixd
    nixfmt
    statix
  ];

  programs = {
    nix-index = {
      enable = true;
      enableZshIntegration = true;
    };
    nix-index-database.comma.enable = true;
  };
}
