{ pkgs, ... }:

{
  home.packages = with pkgs; [
    gnumake
    cmake
    ninja
    pkg-config
    autoconf
    automake
    libtool
    just
    go-task # Task runner (alternative to make)
    nasm
    shellcheck
    shfmt
    treefmt
    editorconfig-core-c
  ];
}
