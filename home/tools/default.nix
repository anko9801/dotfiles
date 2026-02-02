# Common tools - import this in platform configs
{ ... }:

{
  imports = [
    ./bat.nix
    ./cli.nix
    ./claude
    ./git
    ./yazi.nix
    ./zellij.nix
  ];
}
