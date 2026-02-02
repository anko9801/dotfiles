_:

{
  imports = [
    # Shell integrations
    ./direnv.nix

    # Languages
    ./nix.nix
    ./rust.nix
    ./python.nix
    ./node.nix
    ./go.nix
    ./lua.nix

    # Cross-language tools
    ./treefmt.nix
    ./build-tools.nix

    # Version management
    ./mise.nix
    ./nix-index.nix
  ];
}
