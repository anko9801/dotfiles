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
    nasm
    shellcheck
    shfmt
    treefmt
    editorconfig-core-c
  ];
}
