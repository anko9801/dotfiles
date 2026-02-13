{
  description = "NixOS, nix-darwin, and Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-homebrew.url = "github:zhaofengli/nix-homebrew";

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    llm-agents = {
      url = "github:numtide/llm-agents.nix";
    };

    agent-skills = {
      url = "github:Kyure-A/agent-skills-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # External skills
    antfu-skills = {
      url = "github:antfu/skills";
      flake = false;
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      flake-parts,
      home-manager,
      nix-darwin,
      nix-homebrew,
      ...
    }:
    let
      # Get username from environment (falls back to "runner" for pure evaluation)
      username =
        let
          u = builtins.getEnv "USER";
        in
        if u != "" then u else "runner";

      # Factory for creating builders with a specific username
      mkBuilders =
        user:
        let
          systemLib = import ./system/lib.nix {
            inherit nixpkgs home-manager;
            inherit (inputs) llm-agents antfu-skills;
            username = user;
            homeModules = {
              inherit (inputs.nix-index-database.homeModules) nix-index;
              inherit (inputs.nixvim.homeModules) nixvim;
              inherit (inputs.stylix.homeModules) stylix;
              agent-skills = inputs.agent-skills.homeManagerModules.default;
            };
          };
          darwin = import ./system/darwin/builder.nix {
            inherit
              nix-darwin
              nix-homebrew
              systemLib
              ;
          };
          nixos = import ./system/nixos/builder.nix {
            inherit
              nixpkgs
              systemLib
              ;
          };
        in
        {
          inherit
            systemLib
            darwin
            nixos
            ;
          inherit (systemLib) mkStandaloneHome;
          mkDarwin = darwin.mkDarwin { inherit self inputs; };
          mkNixOS = nixos.mkNixOS { inherit self inputs; };
        };

      # Builders for current user (requires --impure for USER env)
      builders = mkBuilders username;
      inherit (builders) mkDarwin mkNixOS;
      inherit (builders.systemLib) mkAllConfigurations mkDeployNodes defaults;

      # Generate all configurations from config.nix hosts
      allConfigs = mkAllConfigurations {
        inherit mkDarwin mkNixOS;
        inputModules = {
          inherit (inputs.disko.nixosModules) disko;
        };
      };

      # Dev tools configuration (pre-commit, treefmt, devShell)
      mkDevTools = import ./system/dev-tools.nix;
    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      imports = [
        inputs.treefmt-nix.flakeModule
        inputs.git-hooks.flakeModule
      ];

      perSystem =
        {
          config,
          pkgs,
          system,
          ...
        }:
        mkDevTools { inherit config pkgs; }
        // {
          # Flake apps
          apps = {
            switch = {
              type = "app";
              program = toString (
                pkgs.writeShellScript "switch" ''
                  set -e
                  TARGET="''${1:-}"
                  if [ "$(uname)" = "Darwin" ]; then
                    [ -z "$TARGET" ] && TARGET="${defaults.darwin}"
                    nix run nix-darwin -- switch --flake ".#$TARGET"
                  elif [ -f /etc/NIXOS ]; then
                    [ -z "$TARGET" ] && TARGET="${defaults.nixos}"
                    sudo nixos-rebuild switch --flake ".#$TARGET"
                  elif [ -n "''${WSL_DISTRO_NAME:-}" ]; then
                    [ -z "$TARGET" ] && TARGET="${defaults.wsl}"
                    nix run home-manager -- switch --impure --flake ".#$TARGET"
                  else
                    [ -z "$TARGET" ] && TARGET="${defaults.linux}"
                    nix run home-manager -- switch --impure --flake ".#$TARGET"
                  fi
                ''
              );
            };
          }
          // (
            if inputs.deploy-rs.packages ? ${system} then
              {
                deploy = {
                  type = "app";
                  program = toString inputs.deploy-rs.packages.${system}.default;
                };
              }
            else
              { }
          );
        };

      flake = {
        inherit (allConfigs) homeConfigurations darwinConfigurations nixosConfigurations;

        # deploy-rs configuration (auto-generated from config.nix hosts with deploy field)
        deploy.nodes = mkDeployNodes {
          inherit self;
          inherit (inputs) deploy-rs;
        };
      };
    };
}
