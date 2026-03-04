# Host configuration generator
# Reads config.nix and produces homeConfigurations for the flake
{ inputs, username }:
let
  inherit (inputs) nixpkgs home-manager;

  cfg = import ../config.nix;

  inherit (cfg)
    coreModules
    baseModules
    ;

  defaults = cfg.defaultHosts;

  userConfig = cfg.users.${username} or (throw "User '${username}' not defined in config.nix");

  mkStandaloneHome =
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
        inherit inputs username userConfig;
      };
      modules =
        coreModules
        ++ baseModules
        ++ extraModules
        ++ [
          {
            home = {
              inherit username;
              homeDirectory = if pkgs.stdenv.isDarwin then "/Users/${username}" else "/home/${username}";
            };
            nix.package = pkgs.nix;
          }
        ];
    };

  homeConfigurations = nixpkgs.lib.mapAttrs (
    _name: host:
    mkStandaloneHome {
      inherit (host) system;
      extraModules = host.modules or [ ];
    }
  ) cfg.hosts;
in
{
  inherit homeConfigurations defaults;
}
