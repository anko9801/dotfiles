{
  description = "Home Manager and nix-darwin configuration for anko";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

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
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      nix-darwin,
      nix-index-database,
      nix-homebrew,
      ...
    }:
    let
      # Common modules for home-manager
      commonHomeModules = [
        ./home.nix
        nix-index-database.homeModules.nix-index
      ];

      # Standalone home-manager configuration (for Linux/WSL)
      mkHome =
        {
          system,
          extraModules ? [ ],
        }:
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
          modules = commonHomeModules ++ extraModules;
        };

      # nix-darwin configuration (for macOS)
      mkDarwin =
        { system, hostname }:
        nix-darwin.lib.darwinSystem {
          inherit system;
          specialArgs = { inherit self; };
          modules = [
            ./darwin/configuration.nix

            # Homebrew management
            nix-homebrew.darwinModules.nix-homebrew
            {
              nix-homebrew = {
                enable = true;
                enableRosetta = system == "aarch64-darwin";
                user = "anko";
                autoMigrate = true;
              };
            }

            # Home Manager as nix-darwin module
            home-manager.darwinModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.anko =
                  { pkgs, ... }:
                  {
                    imports = commonHomeModules ++ [ ./modules/platforms/darwin.nix ];
                  };
              };
            }
          ];
        };
    in
    {
      # Standalone Home Manager configurations (Linux/WSL)
      homeConfigurations = {
        "anko@wsl" = mkHome {
          system = "x86_64-linux";
          extraModules = [ ./modules/platforms/wsl.nix ];
        };

        "anko@linux" = mkHome {
          system = "x86_64-linux";
          extraModules = [ ./modules/platforms/linux.nix ];
        };
      };

      # nix-darwin configurations (macOS)
      darwinConfigurations = {
        # Apple Silicon Mac
        "anko-mac" = mkDarwin {
          system = "aarch64-darwin";
          hostname = "anko-mac";
        };

        # Intel Mac
        "anko-mac-intel" = mkDarwin {
          system = "x86_64-darwin";
          hostname = "anko-mac-intel";
        };
      };
    };
}
