# Common tools - import this in platform configs
{ ... }:

{
  imports = [
    ./bat.nix
    ./cli.nix
    ./claude
    ./ghostty.nix
    ./git
    ./yazi.nix
    # zellij is WSL-only (Ghostty has built-in splits on macOS)
    # ime.nix moved to home/desktop/
  ];
}
