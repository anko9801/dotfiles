{
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    ./syncthing.nix
  ];
}
