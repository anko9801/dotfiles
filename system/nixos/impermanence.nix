# Impermanence: tmpfs root with opt-in state persistence (opt-in module)
# Requires: separate /persist partition (ext4/btrfs) and /nix bind mount
{ lib, ... }:

{
  fileSystems = {
    "/" = lib.mkForce {
      device = "none";
      fsType = "tmpfs";
      options = [
        "defaults"
        "size=4G"
        "mode=755"
      ];
    };
    "/persist" = {
      device = "/dev/disk/by-label/persist";
      fsType = "ext4";
      neededForBoot = true;
    };
    "/nix" = {
      device = "/persist/nix";
      options = [ "bind" ];
    };
  };

  environment.persistence."/persist" = {
    hideMounts = true;
    directories = [
      "/var/log"
      "/var/lib/nixos"
      "/var/lib/systemd"
      "/var/lib/bluetooth"
      "/etc/NetworkManager/system-connections"
      "/etc/ssh"
    ];
    files = [
      "/etc/machine-id"
    ];
  };
}
