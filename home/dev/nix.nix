{ pkgs, ... }:

{
  home.packages = with pkgs; [
    nix-tree
    nix-du
    manix
    nix-diff
    nvd
    devenv
    nixd
    nixfmt
    statix
  ];

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
