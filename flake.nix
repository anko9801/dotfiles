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

      imports = [
        inputs.treefmt-nix.flakeModule
        inputs.git-hooks.flakeModule
      ];

      perSystem =
        { config, pkgs, ... }:
        {
          # Pre-commit hooks
          pre-commit = {
            check.enable = false;
            settings.hooks = {
              treefmt = {
                enable = true;
                package = config.treefmt.build.wrapper;
              };
              deadnix.enable = true;
              statix.enable = true;
            };
          };

          # Treefmt with extended formatters
          treefmt = {
            projectRootFile = "flake.nix";
            programs = {
              nixfmt.enable = true;
              shfmt.enable = true;
              yamlfmt.enable = true;
            };
            settings = {
              global.excludes = [
                ".git/**"
                "*.lock"
              ];
              formatter = {
                fish-indent = {
                  command = "${pkgs.fish}/bin/fish_indent";
                  options = [ "--write" ];
                  includes = [ "*.fish" ];
                };
                gitleaks = {
                  command = "${pkgs.gitleaks}/bin/gitleaks";
                  options = [
                    "detect"
                    "--no-git"
                    "--exit-code"
                    "0"
                  ];
                  includes = [ "*" ];
                  excludes = [
                    "*.png"
                    "*.jpg"
                    "*.gif"
                    "node_modules/**"
                    ".direnv/**"
                  ];
                };
              };
            };
          };

          # DevShell with pre-commit hooks
          devShells.default = pkgs.mkShell {
            shellHook = config.pre-commit.installationScript;
            packages = with pkgs; [
              statix
              deadnix
              nvd
            ];
          };

          # Flake apps for common operations
          apps =
            let
              detectTarget = ''
                if [ "$(uname)" = "Darwin" ]; then
                  if [ "$(uname -m)" = "arm64" ]; then
                    echo "mac"
                  else
                    echo "mac-intel"
                  fi
                elif [ -f /etc/NIXOS ]; then
                  if [ -n "''${WSL_DISTRO_NAME:-}" ]; then
                    echo "nixos-wsl"
                  elif [ -n "''${DISPLAY:-}" ] || [ -n "''${WAYLAND_DISPLAY:-}" ]; then
                    echo "nixos-desktop"
                  else
                    echo "nixos-server"
                  fi
                else
                  if [ -n "''${WSL_DISTRO_NAME:-}" ]; then
                    echo "wsl"
                  elif [ -n "''${DISPLAY:-}" ] || [ -n "''${WAYLAND_DISPLAY:-}" ]; then
                    echo "linux-desktop"
                  else
                    echo "server"
                  fi
                fi
              '';
            in
            {
              switch = {
                type = "app";
                program = toString (
                  pkgs.writeShellScript "switch" ''
                    set -e
                    target=$(${detectTarget})
                    echo "Detected target: $target"
                    case "$target" in
                      mac|mac-intel)
                        sudo nix run nix-darwin -- switch --flake ".#$target"
                        ;;
                      nixos-*)
                        sudo nixos-rebuild switch --flake ".#$target"
                        ;;
                      *)
                        home-manager switch --impure --flake ".#$target"
                        ;;
                    esac
                  ''
                );
              };
              build = {
                type = "app";
                program = toString (
                  pkgs.writeShellScript "build" ''
                    set -e
                    target=$(${detectTarget})
                    echo "Detected target: $target"
                    case "$target" in
                      mac|mac-intel)
                        nix build ".#darwinConfigurations.$target.system"
                        ;;
                      nixos-*)
                        nix build ".#nixosConfigurations.$target.config.system.build.toplevel"
                        ;;
                      *)
                        nix build --impure ".#homeConfigurations.$target.activationPackage"
                        ;;
                    esac
                  ''
                );
              };
              update = {
                type = "app";
                program = toString (
                  pkgs.writeShellScript "update" ''
                    nix flake update
                    echo "Run 'nix run .#switch' to apply"
                  ''
                );
              };
              fmt = {
                type = "app";
                program = toString (
                  pkgs.writeShellScript "fmt" ''
                    exec ${config.treefmt.build.wrapper}/bin/treefmt "$@"
                  ''
                );
              };
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
