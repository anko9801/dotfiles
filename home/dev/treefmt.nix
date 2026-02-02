{ pkgs, ... }:

{
  home.packages = with pkgs; [
    treefmt
    editorconfig-core-c
  ];
}
