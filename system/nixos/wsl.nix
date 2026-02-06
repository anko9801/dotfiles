{
  inputs,
  pkgs,
  username,
  versions,
  ...
}:

let
  nixSettings = import ../nix-settings.nix;
  basePkgs = import ../base-packages.nix pkgs;
in
{
  imports = [
    inputs.nixos-wsl.nixosModules.default
  ];

  wsl = {
    enable = true;
    defaultUser = username;
    startMenuLaunchers = true;
    interop = {
      register = true;
      includePath = true;
    };
  };

  networking.hostName = "nixos-wsl";

  nix = {
    inherit (nixSettings) settings;
    optimise.automatic = true;
    gc = nixSettings.gc // {
      dates = "weekly";
    };
  };

  # System packages
  environment.systemPackages = basePkgs.base ++ basePkgs.nixos;

  # This value determines the NixOS release
  system.stateVersion = versions.nixos;
}
