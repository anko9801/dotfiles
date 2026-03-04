{
  description = "Minimal Nix dotfiles with Home Manager";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ nixpkgs, ... }:
    let
      # Get username from environment (falls back to "runner" for CI)
      username =
        let
          u = builtins.getEnv "USER";
        in
        if u != "" then u else "runner";

      # Host configuration generator (config.nix -> flake outputs)
      systemLib = import ./system/hosts.nix { inherit inputs username; };

      inherit (systemLib) homeConfigurations defaults;

      # forEachSystem: apply a function to each supported system
      forEachSystem =
        f:
        nixpkgs.lib.genAttrs
          [
            "x86_64-linux"
            "aarch64-linux"
            "x86_64-darwin"
            "aarch64-darwin"
          ]
          (
            system:
            f {
              inherit system;
              pkgs = nixpkgs.legacyPackages.${system};
            }
          );
    in
    {
      inherit homeConfigurations;

      # `nix run .#switch` to apply configuration
      apps = forEachSystem (
        { pkgs, ... }:
        {
          switch = {
            type = "app";
            program = toString (
              pkgs.writeShellScript "switch" ''
                set -e
                TARGET="''${1:-}"
                if [ "$(uname)" = "Darwin" ]; then
                  [ -z "$TARGET" ] && TARGET="${defaults.darwin}"
                else
                  [ -z "$TARGET" ] && TARGET="${defaults.linux}"
                fi
                nix run home-manager -- switch --impure --flake ".#$TARGET"
              ''
            );
          };
        }
      );

      # `nix fmt` to format all nix files
      formatter = forEachSystem ({ pkgs, ... }: pkgs.nixfmt-rfc-style);
    };
}
