{
  description = "Home Manager and nix-darwin configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";

    treefmt-nix.url = "github:numtide/treefmt-nix";

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

    haumea = {
      url = "github:nix-community/haumea";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Theming
    stylix.url = "github:danth/stylix";
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
      # User-specific configuration (change this when forking)
      userConfig = import ./user.nix;

      # Common modules for home-manager
      commonHomeModules = [
        ./home.nix
        ./modules/theme.nix
        nix-index-database.homeModules.nix-index
        inputs.nixvim.homeModules.nixvim
        inputs.sops-nix.homeModules.sops
        inputs.stylix.homeModules.stylix
      ];

      # Standalone home-manager configuration (for Linux/WSL)
      mkHome =
        {
          system,
          user,
          extraModules ? [ ],
        }:
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
          extraSpecialArgs = { inherit userConfig; };
          modules =
            commonHomeModules
            ++ extraModules
            ++ [
              {
                home = {
                  username = user;
                  homeDirectory = "/home/${user}";
                };
              }
            ];
        };

      # nix-darwin configuration (for macOS)
      mkDarwin =
        {
          system,
          user ? userConfig.username,
        }:
        nix-darwin.lib.darwinSystem {
          inherit system;
          specialArgs = {
            inherit self inputs userConfig;
          };
          modules = [
            ./darwin/configuration.nix

            # Homebrew management
            nix-homebrew.darwinModules.nix-homebrew
            {
              nix-homebrew = {
                enable = true;
                enableRosetta = system == "aarch64-darwin";
                inherit user;
                autoMigrate = true;
              };
            }

            # Home Manager as nix-darwin module
            home-manager.darwinModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                extraSpecialArgs = { inherit userConfig; };
                users.${user} =
                  { lib, ... }:
                  {
                    imports = commonHomeModules ++ [ ./modules/platforms/darwin.nix ];
                    home = {
                      username = lib.mkForce user;
                      homeDirectory = lib.mkForce "/Users/${user}";
                    };
                  };
              };
            }

            # Override system.primaryUser for the specific user
            {
              system.primaryUser = user;
            }
          ];
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
          "${userConfig.username}@wsl" = mkHome {
            system = "x86_64-linux";
            user = userConfig.username;
            extraModules = [
              ./modules/platforms/wsl.nix
              { programs.wsl.windowsUser = userConfig.windowsUsername; }
            ];
          };

          "${userConfig.username}@linux" = mkHome {
            system = "x86_64-linux";
            user = userConfig.username;
            extraModules = [ ./modules/platforms/linux.nix ];
          };

          "${userConfig.username}@server" = mkHome {
            system = "x86_64-linux";
            user = userConfig.username;
            extraModules = [ ./modules/platforms/server.nix ];
          };
        };

        # nix-darwin configurations (macOS)
        darwinConfigurations = {
          # Apple Silicon Mac
          "${userConfig.username}-mac" = mkDarwin {
            system = "aarch64-darwin";
          };

          # Intel Mac
          "${userConfig.username}-mac-intel" = mkDarwin {
            system = "x86_64-darwin";
          };
        };
      };
    };
}
