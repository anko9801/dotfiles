# Example VPS server configuration
#
# USAGE:
# 1. Copy this directory to create your own VPS config:
#    cp -r system/nixos/example-vps system/nixos/my-vps
#
# 2. Update the following in your new config:
#    - networking.hostName (this file)
#    - system.autoUpgrade.flake (this file) - change "example-vps" to your config name
#    - disko.nix - adjust disk layout if needed
#    - hardware.nix - generate after first boot with: nixos-generate-config --show-hardware-config
#
# 3. Add to flake.nix nixosConfigurations:
#    my-vps = mkNixOS {
#      system = "x86_64-linux";  # or "aarch64-linux" for ARM
#      hostName = "server";
#      extraModules = [
#        inputs.disko.nixosModules.disko
#        ./system/nixos/my-vps
#        ./system/nixos/server.nix
#      ];
#    };
#
# 4. Add to flake.nix deploy.nodes:
#    my-vps = {
#      hostname = "your-server-ip-or-hostname";
#      profiles.system = {
#        user = "root";
#        path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.my-vps;
#      };
#    };
#
# 5. Initial deployment with nixos-anywhere:
#    nix run github:nix-community/nixos-anywhere -- --flake .#my-vps root@your-server-ip
#
# 6. Subsequent updates with deploy-rs:
#    nix run .#deploy -- .#my-vps
#
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

  # Authorized SSH keys from userConfig (set in users.nix)
  users.users.root.openssh.authorizedKeys.keys =
    if (userConfig.sshKey or "") != "" then [ userConfig.sshKey ] else [ ];

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
