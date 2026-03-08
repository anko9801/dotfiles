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

    nixgl = {
      url = "github:nix-community/nixGL";
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

    comin = {
      url = "github:nlewo/comin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    llm-agents = {
      url = "github:numtide/llm-agents.nix";
    };

    agent-skills = {
      url = "github:Kyure-A/agent-skills-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    _1password-shell-plugins = {
      url = "github:1Password/shell-plugins";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    windows-home-manager = {
      url = "path:/home/anko/windows-home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # External skills
    antfu-skills = {
      url = "github:antfu/skills";
      flake = false;
    };
    anthropic-skills = {
      url = "github:anthropics/skills";
      flake = false;
    };
  };

  outputs =
    inputs@{
      self,
      flake-parts,
      ...
    }:
    let
      # Get username from environment (falls back to "runner" for pure evaluation)
      username =
        let
          u = builtins.getEnv "USER";
        in
        if u != "" then u else "runner";

      # Host configuration generator (config.nix → flake outputs)
      systemLib = import ./system/hosts.nix { inherit inputs username; };

      inherit (systemLib) mkAllConfigurations mkDeployNodes defaults;

      # Generate all configurations from config.nix hosts
      allConfigs = mkAllConfigurations { inherit self; };
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
        ./system/dev-tools.nix
      ];

      perSystem =
        {
          config,
          lib,
          pkgs,
          system,
          ...
        }:
        {
          packages = lib.optionalAttrs pkgs.stdenv.isLinux {
            windows = inputs.windows-home-manager.lib.mkWindowsHome {
              inherit pkgs;
              modules = inputs.windows-home-manager.windowsModules.default ++ [
                ./tools/git/windows.nix
                (import ./tools/kanata.nix).windowsModule
                (import ./terminal/windows-terminal.nix).windowsModule
                ./tools/komorebi.nix
                ./tools/whkd.nix
                ./tools/winget.nix
                ./system/windows/wsl.nix
                ./system/windows/registry.nix
                ./system/windows/environment.nix
                {
                  windows.username = "anko";
                  windows.fonts = [ pkgs.moralerspace ];
                }
              ];
            };
          };

          apps = {
            switch = {
              type = "app";
              program = toString (
                pkgs.writeShellScript "switch" ''
                  set -e
                  TARGET="''${1:-}"
                  if [ "$TARGET" = "windows" ]; then
                    echo "Error: Use 'nix run .#windows' for Windows setup"
                    exit 1
                  fi
                  if [ "$(uname)" = "Darwin" ]; then
                    [ -z "$TARGET" ] && TARGET="${defaults.darwin}"
                    nix run nix-darwin -- switch --flake ".#$TARGET"
                  elif [ -f /etc/NIXOS ]; then
                    [ -z "$TARGET" ] && TARGET="${defaults.nixos}"
                    sudo nixos-rebuild switch --flake ".#$TARGET"
                  elif [ -n "''${WSL_DISTRO_NAME:-}" ]; then
                    [ -z "$TARGET" ] && TARGET="${defaults.wsl}"
                    nix run home-manager -- switch --impure -b backup --flake ".#$TARGET"
                  else
                    [ -z "$TARGET" ] && TARGET="${defaults.linux}"
                    nix run home-manager -- switch --impure -b backup --flake ".#$TARGET"
                  fi
                ''
              );
            };
          }
          // lib.optionalAttrs pkgs.stdenv.isLinux {
            windows = {
              type = "app";
              program = "${config.packages.windows}/bin/activate-windows";
            };
          }
          // lib.optionalAttrs (inputs.deploy-rs.packages ? ${system}) {
            deploy = {
              type = "app";
              program = toString inputs.deploy-rs.packages.${system}.default;
            };
          };
        };

      flake = {
        inherit (allConfigs) homeConfigurations darwinConfigurations nixosConfigurations;

        # deploy-rs configuration (auto-generated from config.nix hosts with deploy field)
        deploy.nodes = mkDeployNodes {
          inherit self;
          inherit (inputs) deploy-rs;
        };

        templates.default = {
          description = "Minimal Nix dotfiles with Home Manager";
          path = ./template;
        };
      };
    };
}
