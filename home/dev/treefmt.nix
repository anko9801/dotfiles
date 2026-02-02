{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Formatting infrastructure
    treefmt
    editorconfig-core-c
  ];
}
