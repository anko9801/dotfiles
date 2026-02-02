{
  inputs,
  pkgs,
  ...
}:

let
  nixSettings = import ../nix-settings.nix;
  username =
    let
      envUser = builtins.getEnv "USER";
    in
    if envUser != "" then envUser else "nixuser";
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
    settings = nixSettings;
    optimise.automatic = true;
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };

  # System packages
  environment.systemPackages = with pkgs; [
    git
    vim
    wget
    curl
  ];

  # This value determines the NixOS release
  system.stateVersion = "24.11";
}
