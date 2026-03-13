{
  pkgs,
  lib,
  ...
}:

{
  imports = [ ./ssh.nix ];
  # Default fileSystems (override with disko or hardware-configuration.nix)
  fileSystems."/" = lib.mkDefault {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  boot = {
    loader = {
      systemd-boot.enable = lib.mkDefault true;
      efi.canTouchEfiVariables = lib.mkDefault true;
    };
    kernel.sysctl = {
      # Disable magic SysRq key
      "kernel.sysrq" = 0;
      # TCP SYN flood protection
      "net.ipv4.tcp_syncookies" = 1;
      "net.ipv4.tcp_rfc1337" = 1;
      # TCP performance
      "net.ipv4.tcp_fastopen" = 3;
      "net.ipv4.tcp_congestion_control" = "bbr";
      "net.core.default_qdisc" = "cake";
      # Reject ICMP redirects
      "net.ipv4.conf.all.accept_redirects" = 0;
      "net.ipv4.conf.default.accept_redirects" = 0;
      "net.ipv4.conf.all.secure_redirects" = 0;
      "net.ipv4.conf.default.secure_redirects" = 0;
      "net.ipv6.conf.all.accept_redirects" = 0;
      "net.ipv6.conf.default.accept_redirects" = 0;
      # Don't send ICMP redirects
      "net.ipv4.conf.all.send_redirects" = 0;
      "net.ipv4.conf.default.send_redirects" = 0;
      # Reverse path filtering
      "net.ipv4.conf.default.rp_filter" = 1;
      "net.ipv4.conf.all.rp_filter" = 1;
      # Ignore bogus ICMP errors
      "net.ipv4.icmp_ignore_bogus_error_responses" = 1;
      # Reject source routing
      "net.ipv4.conf.all.accept_source_route" = 0;
      "net.ipv6.conf.all.accept_source_route" = 0;
    };
    kernelModules = [ "tcp_bbr" ];
  };

  networking = {
    hostName = lib.mkDefault "nixos-server";
    networkmanager.enable = true;
    firewall.enable = true;
  };

  services = {
    fwupd.enable = true;
    journald.extraConfig = "SystemMaxUse=1G";
  };

  # Reduce NixOS build time (servers don't need docs)
  documentation = {
    nixos.enable = lib.mkForce false;
    info.enable = false;
    doc.enable = false;
  };

  # Server packages (base packages are in nixModule)
  environment.systemPackages = [ pkgs.htop ];
}
