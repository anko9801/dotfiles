_:

{
  imports = [
    ./bash.nix
    ./zsh
    # fish.nix removed - zsh user, saves 12+ fish completions builds
    ./starship.nix
  ];
}
