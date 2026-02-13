# System builder utilities
{ nixpkgs, username }:
let
  cfg = import ../config.nix;

  inherit (cfg)
    nixSettings
    versions
    basePackages
    desktopFonts
    ;

  # User-specific configuration (must be defined in config.nix)
  userConfig = cfg.users.${username} or (throw "User '${username}' not defined in config.nix");

  allHosts = cfg.hosts;

  # Get host modules from config.nix (already includes baseModules)
  getHostModules = hostName: (allHosts.${hostName} or { }).modules or [ ];

  # Creates unified nix configuration for darwin/nixos
  mkNixConfig =
    {
      isDarwin ? false,
    }:
    {
      inherit (nixSettings) settings;
      optimise.automatic = true;
      gc =
        nixSettings.gc
        // (
          if isDarwin then
            { interval = nixSettings.gcSchedule.darwin; }
          else
            { dates = nixSettings.gcSchedule.frequency; }
        );
    };

  # Unfree package handling with build-time warnings
  setUnfreeWarning =
    maybeAttrs: prefix:
    let
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

  mkUnfreePkgs =
    system:
    setUnfreeWarning (import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    }) "unfreePkgs";

  # Special args for home-manager modules
  mkSpecialArgs = system: {
    inherit
      userConfig
      allHosts
      versions
      nixSettings
      mkNixConfig
      basePackages
      desktopFonts
      ;
    unfreePkgs = mkUnfreePkgs system;
  };

  # Special args for system modules (darwin/nixos)
  mkSystemSpecialArgs =
    { self, inputs }: system: mkSpecialArgs system // { inherit self inputs username; };

  # Factory for creating system builders (darwin/nixos)
  # Reduces duplication between darwin and nixos builders
  mkSystemBuilder =
    {
      systemBuilder, # nix-darwin.lib.darwinSystem or nixpkgs.lib.nixosSystem
      homeManagerModule, # home-manager.darwinModules or home-manager.nixosModules
      homeDir, # "/Users" or "/home"
      mkPlatformModules, # system -> username -> list of platform-specific modules
      mkSystemHomeConfig, # from homeManager
    }:
    { self, inputs }:
    {
      system,
      hostName,
      extraModules ? [ ],
      homeModules ? [ ],
    }:
    let
      hostModules = getHostModules hostName ++ homeModules;
    in
    systemBuilder {
      inherit system;
      specialArgs = mkSystemSpecialArgs { inherit self inputs; } system;
      modules =
        mkPlatformModules system username
        ++ [
          homeManagerModule.home-manager
          (mkSystemHomeConfig {
            inherit system hostModules homeDir;
          })
        ]
        ++ extraModules;
    };
in
{
  inherit
    username
    userConfig
    allHosts
    versions
    nixSettings
    mkNixConfig
    basePackages
    desktopFonts
    getHostModules
    mkSpecialArgs
    mkSystemSpecialArgs
    mkSystemBuilder
    ;
}
