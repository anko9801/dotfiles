# Hardware configuration
# This file is auto-generated after first boot
# Run: nixos-generate-config --show-hardware-config
{ modulesPath, ... }:

{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix") # For VPS/cloud VMs
  ];

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  # After first boot, replace this with actual hardware config:
  # nixos-generate-config --show-hardware-config > hardware.nix
}
