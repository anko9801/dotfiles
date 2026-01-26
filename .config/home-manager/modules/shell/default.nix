{ config, pkgs, lib, ... }:

{
  imports = [
    ./zsh.nix
    ./starship.nix
  ];
}
