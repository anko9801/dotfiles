{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Build tools
    gnumake
    cmake
    ninja # Fast build system
    pkg-config
    autoconf
    automake
    libtool
    just # Task runner

    # Debug/Low-level tools
    nasm # Assembler

    # Shell script linting (build scripts)
    shellcheck
    shfmt
  ];
}
