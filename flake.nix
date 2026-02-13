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
      nix-index-database,
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
            inherit
              nixpkgs
              home-manager
              nix-index-database
              ;
            inherit (inputs)
              nixvim
              stylix
              llm-agents
              agent-skills
              antfu-skills
              ;
            username = user;
          };
          darwin = import ./system/darwin/builder.nix {
            inherit
              nix-darwin
              nix-homebrew
              home-manager
              systemLib
              ;
          };
          nixos = import ./system/nixos/builder.nix {
            inherit
              nixpkgs
              home-manager
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
      inherit (builders) mkStandaloneHome mkDarwin mkNixOS;
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

          # Flake apps
          apps = {
            switch = {
              type = "app";
              program = toString (
                pkgs.writeShellScript "switch" ''
                  set -e
                  TARGET="''${1:-}"
                  if [ "$(uname)" = "Darwin" ]; then
                    [ -z "$TARGET" ] && TARGET="mac"
                    nix run nix-darwin -- switch --flake ".#$TARGET"
                  elif [ -f /etc/NIXOS ]; then
                    [ -z "$TARGET" ] && TARGET="nixos-desktop"
                    sudo nixos-rebuild switch --flake ".#$TARGET"
                  elif [ -n "''${WSL_DISTRO_NAME:-}" ]; then
                    [ -z "$TARGET" ] && TARGET="wsl"
                    nix run home-manager -- switch --impure --flake ".#$TARGET"
                  else
                    [ -z "$TARGET" ] && TARGET="desktop"
                    nix run home-manager -- switch --impure --flake ".#$TARGET"
                  fi
                ''
              );
            };
          };
        };

      flake = {
        homeConfigurations = {
          wsl = mkStandaloneHome {
            system = "x86_64-linux";
            hostName = "wsl";
            homeModules = [
              { programs.wsl.windowsUser = username; }
            ];
          };

          windows = mkStandaloneHome {
            system = "x86_64-linux";
            hostName = "windows";
          };

          desktop = mkStandaloneHome {
            system = "x86_64-linux";
            hostName = "desktop";
          };

          server = mkStandaloneHome {
            system = "x86_64-linux";
            hostName = "server";
          };

          server-arm = mkStandaloneHome {
            system = "aarch64-linux";
            hostName = "server";
          };
        };

        darwinConfigurations = {
          mac = mkDarwin {
            system = "aarch64-darwin";
            hostName = "mac";
            extraModules = [ ./system/darwin/desktop.nix ];
          };
          mac-intel = mkDarwin {
            system = "x86_64-darwin";
            hostName = "mac";
            extraModules = [ ./system/darwin/desktop.nix ];
          };
        };

        nixosConfigurations = {
          nixos-wsl = mkNixOS {
            system = "x86_64-linux";
            hostName = "wsl";
            extraModules = [ ./system/nixos/wsl.nix ];
            homeModules = [
              { programs.wsl.windowsUser = username; }
            ];
          };

          nixos-desktop = mkNixOS {
            system = "x86_64-linux";
            hostName = "desktop";
            extraModules = [
              ./system/nixos/desktop.nix
              ./system/nixos/kanata.nix
            ];
          };

          nixos-server = mkNixOS {
            system = "x86_64-linux";
            hostName = "server";
            extraModules = [ ./system/nixos/server.nix ];
          };

          nixos-server-arm = mkNixOS {
            system = "aarch64-linux";
            hostName = "server";
            extraModules = [ ./system/nixos/server.nix ];
          };

          example-vps = mkNixOS {
            system = "x86_64-linux";
            hostName = "server";
            extraModules = [
              inputs.disko.nixosModules.disko
              ./system/nixos/example-vps
              ./system/nixos/server.nix
            ];
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
        };
      };
    };
}
