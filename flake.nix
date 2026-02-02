{
  description = "NixOS, nix-darwin, and Home Manager configuration";

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

    # NixOS-WSL
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
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
      userConfig = import ./users/anko.nix;

      # Get username from environment (use --impure flag for actual username)
      username =
        let
          envUser = builtins.getEnv "USER";
        in
        if envUser != "" then envUser else "nixuser";

      # Warn on unfree package access (recursive attribute wrapper)
      setUnfreeWarning =
        maybeAttrs: prefix:
        let
          withoutWarning =
            if builtins.isAttrs maybeAttrs then
              builtins.mapAttrs (name: value: setUnfreeWarning value "${prefix}.${name}") maybeAttrs
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

      # Common modules for home-manager
      commonHomeModules = [
        ./home
        ./theme
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
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs { inherit system; };
          extraSpecialArgs = {
            inherit userConfig;
            unfree-pkgs = mkUnfreePkgs system;
          };
          modules =
            commonHomeModules
            ++ extraModules
            ++ [
              {
                home = {
                  inherit username;
                  homeDirectory = "/home/${username}";
                };
              }
            ];
        };

      # nix-darwin configuration (for macOS)
      mkDarwin =
        { system }:
        nix-darwin.lib.darwinSystem {
          inherit system;
          specialArgs = {
            inherit self inputs userConfig;
            unfree-pkgs = mkUnfreePkgs system;
          };
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
                extraSpecialArgs = {
                  inherit userConfig;
                  unfree-pkgs = mkUnfreePkgs system;
                };
                users.${username} =
                  { lib, ... }:
                  {
                    imports = commonHomeModules ++ [ ./home/os/darwin.nix ];
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
          specialArgs = {
            inherit self inputs userConfig;
            unfree-pkgs = mkUnfreePkgs system;
          };
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
                extraSpecialArgs = {
                  inherit userConfig;
                  unfree-pkgs = mkUnfreePkgs system;
                };
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
              ./home/os/wsl.nix
              { programs.wsl.windowsUser = username; }
            ];
          };

          linux = mkHome {
            system = "x86_64-linux";
            extraModules = [ ./home/os/linux.nix ];
          };

          server = mkHome {
            system = "x86_64-linux";
            extraModules = [ ./home/os/server.nix ];
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
              imports = [ ./home/os/wsl.nix ];
              programs.wsl.windowsUser = username;
            };
          };

          # NixOS desktop
          nixos-desktop = mkNixOS {
            system = "x86_64-linux";
            extraModules = [ ./system/nixos/desktop.nix ];
            homeModule = ./home/os/linux.nix;
          };

          # NixOS server
          nixos-server = mkNixOS {
            system = "x86_64-linux";
            extraModules = [ ./system/nixos/server.nix ];
            homeModule = ./home/os/server.nix;
          };
        };
      };
    };
}
