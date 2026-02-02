{
  inputs,
  pkgs,
  ...
}:

let
  # Get username from environment with fallback
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

    # Windows interop
    interop = {
      register = true;
      includePath = true;
    };
  };

  # Basic system configuration
  networking.hostName = "nixos-wsl";

  # Enable nix command and flakes
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

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
