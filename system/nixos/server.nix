{ pkgs, lib, ... }:

let
  nixSettings = import ../nix-settings.nix;
in
{
  # NOTE: Replace with hardware-configuration.nix after installing NixOS
  # imports = [ ./hardware-configuration.nix ];
  # Default fileSystems (override with disko or hardware-configuration.nix)
  fileSystems."/" = lib.mkDefault {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  networking = {
    hostName = lib.mkDefault "nixos-server";
    networkmanager.enable = true;
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 ];
    };
  };

  time.timeZone = "Asia/Tokyo";
  i18n.defaultLocale = "en_US.UTF-8";

  nix = {
    inherit (nixSettings) settings;
    optimise.automatic = true;
    gc = nixSettings.gc // {
      dates = "weekly";
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

  # System packages
  environment.systemPackages = with pkgs; [
    git
    vim
    wget
    curl
    htop
  ];

  # This value determines the NixOS release
  system.stateVersion = "24.11";
}
