{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Go LSP
    gopls
  ];
}
