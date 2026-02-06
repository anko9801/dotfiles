# Example VPS server configuration
# Copy this directory and customize for your server
{ versions, userConfig, ... }:

{
  imports = [
    ./disko.nix # Disk configuration
    ./hardware.nix # Hardware-specific (generate after first boot)
  ];

  networking = {
    hostName = "example-vps";
    firewall = {
      enable = true;
      allowedTCPPorts = [
        22
        80
        443
      ];
    };
  };

  # SSH hardening
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "prohibit-password"; # Allow root for nixos-anywhere, then disable
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };

  # Authorized SSH keys from userConfig (set in users/$USER.nix)
  users.users.root.openssh.authorizedKeys.keys =
    if userConfig.git.sshKey != "" then [ userConfig.git.sshKey ] else [ ];

  # Automatic updates
  system.autoUpgrade = {
    enable = true;
    flake = "github:anko9801/dotfiles#example-vps";
    flags = [
      "--update-input"
      "nixpkgs"
    ];
    dates = "04:00";
    allowReboot = true;
  };

  # This value determines the NixOS release
  system.stateVersion = versions.nixos;
}
