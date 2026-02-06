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

    # NixOS-WSL
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Declarative disk partitioning
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Theming
    stylix = {
      url = "github:danth/stylix";
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
      # Get username from environment (use --impure flag for actual username)
      username =
        let
          envUser = builtins.getEnv "USER";
        in
        if envUser != "" then envUser else "nixuser";

      # User-specific configuration (with fallback to default)
      userConfig =
        let
          userFile = ./users/${username}.nix;
        in
        if builtins.pathExists userFile then import userFile else import ./users/default.nix;

      # Log unfree package usage at build time (helps track non-FOSS dependencies)
      setUnfreeWarning =
        maybeAttrs: prefix:
        let
          # Skip derivation outputs to avoid duplicate warnings (foo and foo.out)
          outputNames = [
            "out"
            "dev"
            "lib"
            "bin"
            "man"
            "doc"
            "info"
          ];
          withoutWarning =
            if builtins.isAttrs maybeAttrs then
              builtins.mapAttrs (
                name: value:
                if builtins.elem name outputNames then value else setUnfreeWarning value "${prefix}.${name}"
              ) maybeAttrs
            else
              maybeAttrs;
        in
        if nixpkgs.lib.isDerivation withoutWarning then
          builtins.warn "Using UNFREE package: ${prefix}" withoutWarning
        else
          withoutWarning;

      # Unfree packages helper
      mkUnfreePkgs =
        system:
        setUnfreeWarning (import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        }) "unfreePkgs";

      # Common specialArgs for home-manager
      mkSpecialArgs = system: {
        inherit userConfig;
        unfreePkgs = mkUnfreePkgs system;
      };

      # System-level specialArgs (for nix-darwin and NixOS modules)
      mkSystemSpecialArgs = system: mkSpecialArgs system // { inherit self inputs; };

      # Common modules for home-manager
      commonHomeModules = [
        # Core
        ./home/platform.nix
        ./home/core.nix
        # Dev
        ./home/dev/build-tools.nix
        ./home/dev/go.nix
        ./home/dev/mise.nix
        ./home/dev/nix.nix
        ./home/dev/node.nix
        ./home/dev/python.nix
        ./home/dev/rust.nix
        # Security
        ./home/security/1password.nix
        ./home/security/gitleaks.nix
        ./home/security/gpg.nix
        ./home/security/ssh.nix
        ./home/security/trivy.nix
        # Shell
        ./home/shell/aliases.nix
        ./home/shell/atuin.nix
        ./home/shell/bash.nix
        ./home/shell/eza.nix
        ./home/shell/fish.nix
        ./home/shell/fzf.nix
        ./home/shell/readline.nix
        ./home/shell/starship.nix
        ./home/shell/zoxide.nix
        ./home/shell/zsh/aliases.nix
        ./home/shell/zsh/completion.nix
        ./home/shell/zsh/functions.nix
        ./home/shell/zsh/obsidian.nix
        ./home/shell/zsh/zsh.nix
        # Theme
        ./theme/catppuccin-mocha.nix
        ./theme/default.nix
        # External
        nix-index-database.homeModules.nix-index
        inputs.nixvim.homeModules.nixvim
        inputs.stylix.homeModules.stylix
      ];

      # Standalone home-manager configuration (for Linux/WSL)
      mkHome =
        {
          system,
          extraModules ? [ ],
        }:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = mkSpecialArgs system;
          modules =
            commonHomeModules
            ++ extraModules
            ++ [
              {
                home = {
                  inherit username;
                  homeDirectory = "/home/${username}";
                };
                nix.package = pkgs.nix; # Required for standalone home-manager
              }
            ];
        };

      # nix-darwin configuration (for macOS)
      mkDarwin =
        { system }:
        nix-darwin.lib.darwinSystem {
          inherit system;
          specialArgs = mkSystemSpecialArgs system;
          modules = [
            ./system/darwin

            # Homebrew management
            nix-homebrew.darwinModules.nix-homebrew
            {
              nix-homebrew = {
                enable = true;
                enableRosetta = system == "aarch64-darwin";
                user = username;
                autoMigrate = true;
              };
            }

            # Home Manager as nix-darwin module
            home-manager.darwinModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                extraSpecialArgs = mkSpecialArgs system;
                users.${username} =
                  { lib, ... }:
                  {
                    imports = commonHomeModules;
                    home = {
                      username = lib.mkForce username;
                      homeDirectory = lib.mkForce "/Users/${username}";
                    };
                  };
              };
            }

            # Override system.primaryUser for the specific user
            {
              system.primaryUser = username;
            }
          ];
        };

      # NixOS configuration
      mkNixOS =
        {
          system,
          extraModules ? [ ],
          homeModule,
        }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = mkSystemSpecialArgs system;
          modules = [
            # User configuration
            {
              users.users.${username} = {
                isNormalUser = true;
                extraGroups = [
                  "wheel"
                  "networkmanager"
                ];
              };
            }

            # Home Manager as NixOS module
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                extraSpecialArgs = mkSpecialArgs system;
                users.${username} =
                  { lib, ... }:
                  {
                    imports = commonHomeModules ++ [ homeModule ];
                    home = {
                      username = lib.mkForce username;
                      homeDirectory = lib.mkForce "/home/${username}";
                    };
                  };
              };
            }
          ]
          ++ extraModules;
        };
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
      ];

      perSystem =
        { pkgs, ... }:
        {
          # Unified formatting with treefmt
          treefmt = {
            projectRootFile = "flake.nix";
            programs = {
              nixfmt.enable = true;
              shfmt.enable = true;
              yamlfmt.enable = true;
            };
          };

          # Development shell for working on this config (minimal)
          devShells.default = pkgs.mkShell {
            packages = with pkgs; [
              statix # Linter
              deadnix # Dead code finder
              nvd # Version diff (lightweight)
              # Heavy tools (nix-tree, nix-du, nix-diff, manix) available via `nix run nixpkgs#<tool>`
            ];
          };
        };

      flake = {
        # Standalone Home Manager configurations (Linux/WSL)
        homeConfigurations = {
          wsl = mkHome {
            system = "x86_64-linux";
            extraModules = [
              ./system/wsl.nix
              { programs.wsl.windowsUser = username; }
            ];
          };

          linux-desktop = mkHome {
            system = "x86_64-linux";
            extraModules = [
              ./system/linux-desktop.nix
              ./home/desktop
            ];
          };

          server = mkHome {
            system = "x86_64-linux";
            extraModules = [ ./system/linux-server.nix ];
          };
        };

        # nix-darwin configurations (macOS)
        darwinConfigurations = {
          # Apple Silicon Mac
          mac = mkDarwin {
            system = "aarch64-darwin";
          };

          # Intel Mac
          mac-intel = mkDarwin {
            system = "x86_64-darwin";
          };
        };

        # NixOS configurations
        nixosConfigurations = {
          # NixOS on WSL
          nixos-wsl = mkNixOS {
            system = "x86_64-linux";
            extraModules = [ ./system/nixos/wsl.nix ];
            homeModule = {
              imports = [ ./system/wsl.nix ];
              programs.wsl.windowsUser = username;
            };
          };

          # NixOS desktop (Niri)
          nixos-desktop = mkNixOS {
            system = "x86_64-linux";
            extraModules = [
              ./system/nixos/desktop.nix
              ./system/nixos/kanata.nix
            ];
            homeModule = {
              imports = [
                ./system/linux-desktop.nix
                ./home/desktop
              ];
            };
          };

          # NixOS server (generic)
          nixos-server = mkNixOS {
            system = "x86_64-linux";
            extraModules = [ ./system/nixos/server.nix ];
            homeModule = ./system/linux-server.nix;
          };

          # Example VPS (for nixos-anywhere deployment)
          example-vps = mkNixOS {
            system = "x86_64-linux";
            extraModules = [
              inputs.disko.nixosModules.disko
              ./system/nixos/example-vps
              ./system/nixos/server.nix
            ];
            homeModule = ./system/linux-server.nix;
          };
        };

        # Apps for deployment
        apps.x86_64-linux = {
          # Deploy to server: nix run .#deploy -- root@server example-vps
          deploy = {
            type = "app";
            program = toString (
              nixpkgs.legacyPackages.x86_64-linux.writeShellScript "deploy" ''
                set -e
                if [ $# -lt 2 ]; then
                  echo "Usage: nix run .#deploy -- <user@host> <config-name>"
                  echo "Example: nix run .#deploy -- root@192.168.1.100 example-vps"
                  exit 1
                fi
                TARGET="$1"
                CONFIG="$2"
                echo "Deploying $CONFIG to $TARGET..."
                nix run github:nix-community/nixos-anywhere -- --flake ".#$CONFIG" "$TARGET"
              ''
            );
          };
        };
      };
    };
}
