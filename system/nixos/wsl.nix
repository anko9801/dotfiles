{
  inputs,
  pkgs,
  username,
  versions,
  nixSettings,
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

  nix = {
    inherit (nixSettings) settings;
    optimise.automatic = true;
    gc = nixSettings.gc // {
      dates = nixSettings.gcSchedule.frequency;
    };
  };

  # System packages
  environment.systemPackages = with pkgs; [
    git
    vim
    curl
    wget
  ];

  # This value determines the NixOS release
  system.stateVersion = versions.nixos;
}
