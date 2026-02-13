# System builder utilities
{ nixpkgs }:
let
  cfg = import ../config.nix;

  inherit (cfg)
    nixSettings
    versions
    basePackages
    desktopFonts
    ;

  # Get username from environment (use --impure flag)
  username =
    let
      envUser = builtins.getEnv "USER";
    in
    if envUser != "" then envUser else "nixuser";

  # User-specific configuration (with fallback)
  userConfig =
    cfg.users.${username} or {
      name = username;
      email = "${username}@localhost";
    };

  allHosts = cfg.hosts;

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
    mkSpecialArgs
    mkSystemSpecialArgs
    ;
}
