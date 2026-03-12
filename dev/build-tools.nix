{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # keep-sorted start
    autoconf
    automake
    cmake
    editorconfig-core-c
    gnumake
    go-task
    just
    libtool
    nasm
    ninja
    pkg-config
    shellcheck
    shfmt
    treefmt
    # keep-sorted end
  ];
}
