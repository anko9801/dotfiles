{
  description = "Minimal Nix dotfiles with Home Manager";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:danth/stylix";
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
      # `nix run .#windows` to deploy Windows config from WSL
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
                elif [ -n "''${WSL_DISTRO_NAME:-}" ]; then
                  [ -z "$TARGET" ] && TARGET="${defaults.wsl}"
                else
                  [ -z "$TARGET" ] && TARGET="${defaults.linux}"
                fi
                nix run home-manager -- switch --impure --backup-ext backup --flake ".#$TARGET"
              ''
            );
          };
          windows = {
            type = "app";
            program = toString ./system/windows/setup.sh;
          };
        }
      );

      # `nix fmt` to format all nix files
      formatter = forEachSystem ({ pkgs, ... }: pkgs.nixfmt-rfc-style);
    };
}
