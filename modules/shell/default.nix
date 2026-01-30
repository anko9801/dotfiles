_:

{
  imports = [
    ./bash.nix
    ./zsh.nix
    # fish.nix removed - zsh user, saves 12+ fish completions builds
    ./starship.nix
  ];
}
