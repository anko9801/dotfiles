# Secure Boot via lanzaboote (opt-in module)
# Setup: sudo sbctl create-keys && sudo sbctl enroll-keys --microsoft
{ lib, pkgs, ... }:

{
  boot = {
    loader.systemd-boot.enable = lib.mkForce false;
    lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/secureboot";
    };
  };

  environment.systemPackages = [ pkgs.sbctl ];
}
