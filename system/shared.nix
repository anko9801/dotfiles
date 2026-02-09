# Shared configuration across all system types
{ nixpkgs }:
let
  # Nix daemon settings
  nixSettings = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
        "https://devenv.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
      ];
      accept-flake-config = true;
      keep-derivations = true;
      keep-outputs = true;
      max-jobs = "auto";
    };
    gc = {
      automatic = true;
      options = "--delete-older-than 30d";
    };
    gcSchedule = {
      darwin = {
        Weekday = 0;
        Hour = 3;
        Minute = 0;
      };
      frequency = "weekly";
    };
  };

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
    home = "24.11";
    nixos = "24.11";
    darwin = 5;
  };

  # Log unfree package usage at build time
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
