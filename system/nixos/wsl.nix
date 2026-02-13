{
  inputs,
  pkgs,
  username,
  versions,
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

  environment.systemPackages = basePackages pkgs;

  # This value determines the NixOS release
  system.stateVersion = versions.nixos;
}
