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

    # Filesystem-based module loader
    haumea = {
      url = "github:nix-community/haumea";
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
      haumea,
      ...
    }:
    let
      # Load all module paths from a directory using haumea
      loadModulePaths =
        {
          src,
          exclude ? [ ],
        }:
        let
          paths = haumea.lib.load {
            inherit src;
            loader = haumea.lib.loaders.path;
          };
          # Remove excluded keys from attrset
          filterExcluded = attrs: builtins.removeAttrs attrs exclude;
          flatten =
            attrs:
            builtins.concatLists (
              builtins.attrValues (
                builtins.mapAttrs (_: value: if builtins.isAttrs value then flatten value else [ value ]) (
                  filterExcluded attrs
                )
              )
            );
        in
        flatten paths;

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

      # Common modules for home-manager (loaded via haumea)
      commonHomeModules =
        loadModulePaths {
          src = ./home;
          exclude = [
            "os-specific"
            "tools"
            "editor"
          ]; # Imported explicitly per platform
        }
        ++ loadModulePaths { src = ./theme; }
        ++ [
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
          extraSpecialArgs = {
            inherit userConfig;
            unfreePkgs = mkUnfreePkgs system;
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
                nix.package = pkgs.nix; # Required for standalone home-manager
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
            unfreePkgs = mkUnfreePkgs system;
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
                  unfreePkgs = mkUnfreePkgs system;
                };
                users.${username} =
                  { lib, ... }:
                  {
                    imports = commonHomeModules ++ [ ./home/os-specific/darwin.nix ];
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
            unfreePkgs = mkUnfreePkgs system;
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
                  unfreePkgs = mkUnfreePkgs system;
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
              ./home/os-specific/wsl.nix
              { programs.wsl.windowsUser = username; }
            ];
          };

          linux = mkHome {
            system = "x86_64-linux";
            extraModules = [ ./home/os-specific/linux.nix ];
          };

          server = mkHome {
            system = "x86_64-linux";
            extraModules = [ ./home/os-specific/server.nix ];
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
              imports = [ ./home/os-specific/wsl.nix ];
              programs.wsl.windowsUser = username;
            };
          };

          # NixOS desktop
          nixos-desktop = mkNixOS {
            system = "x86_64-linux";
            extraModules = [ ./system/nixos/desktop.nix ];
            homeModule = ./home/os-specific/linux.nix;
          };

          # NixOS server
          nixos-server = mkNixOS {
            system = "x86_64-linux";
            extraModules = [ ./system/nixos/server.nix ];
            homeModule = ./home/os-specific/server.nix;
          };
        };
      };
    };
}
