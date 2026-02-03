# Common tools - import this in platform configs
{ ... }:

{
  imports = [
    ./bat.nix
    ./cli.nix
    ./claude
    ./ghostty.nix
    ./git
    ./ime.nix
    ./yazi.nix
    ./zellij
  ];
}
