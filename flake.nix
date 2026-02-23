{
  description = "Minimal Home Manager configuration — starter template";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, home-manager, ... }:
    let
      config = import ./config.nix;

      # Core home-manager module (platform detection + defaults)
      coreModule =
        { lib, config, ... }:
        let
          cfg = config.defaults;
          isWsl = builtins.pathExists /proc/sys/fs/binfmt_misc/WSLInterop;
        in
        {
          options = {
            platform = {
              os = lib.mkOption {
                type = lib.types.enum [ "linux" ];
                readOnly = true;
                default = "linux";
              };
              environment = lib.mkOption {
                type = lib.types.enum [
                  "native"
                  "wsl"
                ];
                readOnly = true;
                default = if isWsl then "wsl" else "native";
              };
            };

            defaults = {
              editor = lib.mkOption {
                type = lib.types.str;
                default = "vim";
              };
              identity = {
                name = lib.mkOption {
                  type = lib.types.nullOr lib.types.str;
                  default = null;
                };
                email = lib.mkOption {
                  type = lib.types.nullOr lib.types.str;
                  default = null;
                };
              };
              locale.lang = lib.mkOption {
                type = lib.types.str;
                default = "en_US.UTF-8";
              };
            };
          };

          config = {
            targets.genericLinux.enable = true;

            home = {
              preferXdgDirectories = true;
              sessionVariables = {
                EDITOR = cfg.editor;
                VISUAL = cfg.editor;
                LANG = cfg.locale.lang;
              };
            };

            xdg.enable = true;
            programs.home-manager.enable = true;
          };
        };

      mkHome =
        name: hostDef:
        let
          pkgs = nixpkgs.legacyPackages.${hostDef.system};
          userConfig = config.users.${hostDef.user};
        in
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            coreModule
            {
              home = {
                username = builtins.getEnv "USER";
                homeDirectory = builtins.getEnv "HOME";
                stateVersion = config.versions.home;
              };
              defaults = {
                editor = userConfig.editor or "vim";
                identity = {
                  name = userConfig.git.name or null;
                  email = userConfig.git.email or null;
                };
              };
            }
          ]
          ++ hostDef.modules;
        };

      homeConfigurations = builtins.mapAttrs mkHome config.hosts;

      systems = nixpkgs.lib.unique (nixpkgs.lib.mapAttrsToList (_: h: h.system) config.hosts);

      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
    in
    {
      inherit homeConfigurations;

      apps = forAllSystems (pkgs: {
        switch = {
          type = "app";
          program = toString (
            pkgs.writeShellScript "switch" ''
              set -e
              TARGET="''${1:-}"
              if [ -n "''${WSL_DISTRO_NAME:-}" ]; then
                [ -z "$TARGET" ] && TARGET="${config.defaultHosts.wsl}"
              else
                [ -z "$TARGET" ] && TARGET="${config.defaultHosts.linux}"
              fi
              nix run home-manager -- switch --impure --flake ".#$TARGET"
            ''
          );
        };
      });
    };
}
