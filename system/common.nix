# Common configuration shared across all system types
{ nixpkgs }:
let
  # Import nix settings from separate file
  nixSettings = import ./nix.nix;

  # Get username from environment (use --impure flag for actual username)
  username =
    let
      envUser = builtins.getEnv "USER";
    in
    if envUser != "" then envUser else "nixuser";

  # User-specific configuration (with fallback to default)
  userConfig =
    let
      userFile = ../users/${username}.nix;
    in
    if builtins.pathExists userFile then import userFile else import ../users/default.nix;

  # Centralized version management
  versions = {
    home = "24.11"; # Home Manager stateVersion
    nixos = "24.11"; # NixOS stateVersion
    darwin = 5; # nix-darwin stateVersion (integer)
  };

  # Log unfree package usage at build time (helps track non-FOSS dependencies)
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

  mkSpecialArgs = system: {
    inherit userConfig versions nixSettings;
    unfreePkgs = mkUnfreePkgs system;
  };

  mkSystemSpecialArgs =
    { self, inputs }: system: mkSpecialArgs system // { inherit self inputs username; };
in
{
  inherit
    username
    userConfig
    versions
    nixSettings
    mkSpecialArgs
    mkSystemSpecialArgs
    ;
}
