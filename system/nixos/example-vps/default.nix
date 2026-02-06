# Example VPS server configuration
# Copy this directory and customize for your server
{ versions, ... }:

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

  # Authorized SSH keys (add your public key)
  users.users.root.openssh.authorizedKeys.keys = [
    # "ssh-ed25519 AAAA... your-key"
  ];

  # Automatic updates
  system.autoUpgrade = {
    enable = true;
    flake = "github:YOUR_USER/dotfiles#example-vps";
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
