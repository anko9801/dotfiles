{
  inputs,
  pkgs,
  username,
  versions,
  mkNixConfig,
  basePackages,
  ...
}:

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

  nix = mkNixConfig { };

  environment.systemPackages = basePackages pkgs;

  # This value determines the NixOS release
  system.stateVersion = versions.nixos;
}
