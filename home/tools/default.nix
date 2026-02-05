# Common tools - import this in platform configs
{ ... }:

{
  imports = [
    ./bat.nix
    ./cli.nix
    ./claude
    ./ghostty.nix
    ./git
    ./kanata.nix
    ./yazi.nix
    # zellij: imported separately in platform configs (WSL uses zellij, macOS uses Ghostty splits)
    # ime.nix moved to home/desktop/
  ];
}
