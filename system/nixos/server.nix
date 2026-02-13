{
  pkgs,
  lib,
  ...
}:

{
  # Default fileSystems (override with disko or hardware-configuration.nix)
  fileSystems."/" = lib.mkDefault {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  boot.loader = {
    systemd-boot.enable = lib.mkDefault true;
    efi.canTouchEfiVariables = lib.mkDefault true;
  };

  networking = {
    hostName = lib.mkDefault "nixos-server";
    networkmanager.enable = true;
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 ];
    };
  };

  # SSH
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = lib.mkDefault "no";
      PasswordAuthentication = lib.mkDefault false;
    };
  };

  # Server packages (base packages are in nixModule)
  environment.systemPackages = [ pkgs.htop ];
}
