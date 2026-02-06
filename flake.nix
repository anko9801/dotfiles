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
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      flake-parts,
      home-manager,
      nix-darwin,
      nix-index-database,
      nix-homebrew,
      ...
    }:
    let
      # Import system builders
      common = import ./system/common.nix { inherit nixpkgs; };

      linux = import ./system/linux {
        inherit
          nixpkgs
          home-manager
          nix-index-database
          common
          ;
        inherit (inputs) nixvim stylix;
      };

      darwin = import ./system/darwin {
        inherit
          nix-darwin
          nix-homebrew
          home-manager
          common
          ;
        home = linux;
      };

      nixos = import ./system/nixos {
        inherit
          nixpkgs
          home-manager
          common
          ;
        home = linux;
      };

      # Bind self and inputs to builders
      inherit (linux) mkHome;
      mkDarwin = darwin.mkDarwin { inherit self inputs; };
      mkNixOS = nixos.mkNixOS { inherit self inputs; };
    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      imports = [ inputs.treefmt-nix.flakeModule ];

      perSystem =
        { pkgs, ... }:
        {
          treefmt = {
            projectRootFile = "flake.nix";
            programs = {
              nixfmt.enable = true;
              shfmt.enable = true;
              yamlfmt.enable = true;
            };
          };

          devShells.default = pkgs.mkShell {
            packages = with pkgs; [
              statix
              deadnix
              nvd
            ];
          };
        };

      flake = {
        homeConfigurations = {
          wsl = mkHome {
            system = "x86_64-linux";
            extraModules = [
              ./system/linux/wsl.nix
              { programs.wsl.windowsUser = common.username; }
            ];
          };

          linux-desktop = mkHome {
            system = "x86_64-linux";
            extraModules = [ ./system/linux/linux-desktop.nix ];
          };

          server = mkHome {
            system = "x86_64-linux";
            workstation = false;
            extraModules = [ ./system/linux/linux-server.nix ];
          };
        };

        darwinConfigurations = {
          mac = mkDarwin { system = "aarch64-darwin"; };
          mac-intel = mkDarwin { system = "x86_64-darwin"; };
        };

        nixosConfigurations = {
          nixos-wsl = mkNixOS {
            system = "x86_64-linux";
            extraModules = [ ./system/nixos/wsl.nix ];
            homeModule = {
              imports = [ ./system/linux/wsl.nix ];
              programs.wsl.windowsUser = common.username;
            };
          };

          nixos-desktop = mkNixOS {
            system = "x86_64-linux";
            extraModules = [
              ./system/nixos/desktop.nix
              ./system/nixos/kanata.nix
            ];
            homeModule = ./system/linux/linux-desktop.nix;
          };

          nixos-server = mkNixOS {
            system = "x86_64-linux";
            extraModules = [ ./system/nixos/server.nix ];
            homeModule = ./system/linux/linux-server.nix;
          };

          example-vps = mkNixOS {
            system = "x86_64-linux";
            extraModules = [
              inputs.disko.nixosModules.disko
              ./system/nixos/example-vps
              ./system/nixos/server.nix
            ];
            homeModule = ./system/linux/linux-server.nix;
          };
        };

        # deploy-rs configuration
        deploy.nodes = {
          example-vps = {
            hostname = "example-vps"; # Replace with actual hostname/IP
            profiles.system = {
              user = "root";
              path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.example-vps;
            };
          };
          nixos-server = {
            hostname = "nixos-server"; # Replace with actual hostname/IP
            profiles.system = {
              user = "root";
              path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.nixos-server;
            };
          };
        };

        apps.x86_64-linux = {
          # deploy-rs for updates
          deploy = {
            type = "app";
            program = toString inputs.deploy-rs.packages.x86_64-linux.default;
          };

          # nixos-anywhere for initial deployment
          deploy-anywhere = {
            type = "app";
            program = toString (
              nixpkgs.legacyPackages.x86_64-linux.writeShellScript "deploy-anywhere" ''
                set -e
                if [ $# -lt 2 ]; then
                  echo "Usage: nix run .#deploy-anywhere -- <user@host> <config-name>"
                  echo "Example: nix run .#deploy-anywhere -- root@192.168.1.100 example-vps"
                  exit 1
                fi
                TARGET="$1"
                CONFIG="$2"
                echo "Deploying $CONFIG to $TARGET with nixos-anywhere..."
                nix run github:nix-community/nixos-anywhere -- --flake ".#$CONFIG" "$TARGET"
              ''
            );
          };
        };
      };
    };
}
