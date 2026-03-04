# Host configuration generator
# Reads config.nix and produces homeConfigurations for the flake
{ inputs, username }:
let
  inherit (inputs) nixpkgs home-manager;

  cfg = import ../config.nix;

  # Home-manager modules from flake inputs
  flakeHomeModules = [
    "stylix"
  ];

  resolveFlakeModule =
    name:
    inputs.${name}.homeModules.${name} or inputs.${name}.homeModules.default
      or inputs.${name}.homeManagerModules.default or inputs.${name}.hmModules.default
        or (throw "flakeHomeModule '${name}' not found");

  flakeModules = map resolveFlakeModule flakeHomeModules;

  inherit (cfg)
    coreModules
    baseModules
    ;

  defaults = cfg.defaultHosts;

  userConfig = cfg.users.${username} or (throw "User '${username}' not defined in config.nix");

  mkStandaloneHome =
    {
      system,
      hostConfig,
      extraModules ? [ ],
    }:
    let
      pkgs = import nixpkgs { inherit system; };
    in
    home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      extraSpecialArgs = {
        inherit
          inputs
          username
          userConfig
          hostConfig
          ;
      };
      modules =
        coreModules
        ++ flakeModules
        ++ baseModules
        ++ extraModules
        ++ [
          {
            home = {
              inherit username;
              homeDirectory = if pkgs.stdenv.isDarwin then "/Users/${username}" else "/home/${username}";
            };

            nix = {
              package = pkgs.nix;
              settings = {
                experimental-features = [
                  "nix-command"
                  "flakes"
                ];
                substituters = [
                  "https://cache.nixos.org"
                  "https://nix-community.cachix.org"
                ];
                trusted-public-keys = [
                  "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
                  "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
                ];
              };
              gc = {
                automatic = true;
                options = "--delete-older-than 30d";
              };
            };

            stylix.overlays.enable = false;
          }
        ];
    };

  homeConfigurations = nixpkgs.lib.mapAttrs (
    _name: host:
    mkStandaloneHome {
      inherit (host) system;
      hostConfig = host;
      extraModules = host.modules or [ ];
    }
  ) cfg.hosts;
in
{
  inherit homeConfigurations defaults;
}
