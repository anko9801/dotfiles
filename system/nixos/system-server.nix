{
  pkgs,
  lib,
  versions,
  ...
}:

let
  nixSettings = import ../nix-settings.nix;
  basePkgs = import ../base-packages.nix pkgs;
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
      dates = nixSettings.gcSchedule.frequency;
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
  environment.systemPackages = basePkgs.base ++ basePkgs.nixos ++ basePkgs.server;

  # This value determines the NixOS release
  system.stateVersion = versions.nixos;
}
