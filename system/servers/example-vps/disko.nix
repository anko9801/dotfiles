# Disk configuration for nixos-anywhere
# https://github.com/nix-community/disko
_:

{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/sda"; # Change to your disk (e.g., /dev/vda, /dev/nvme0n1)
        content = {
          type = "gpt";
          partitions = {
            # EFI System Partition (for UEFI boot)
            ESP = {
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            # Root partition
            root = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };
          };
        };
      };
    };
  };
}
