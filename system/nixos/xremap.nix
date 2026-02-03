# xremap - Key remapper for Linux (NixOS desktop only)
# https://github.com/k0kubun/xremap
# Note: Does NOT work on WSL (no access to input devices)
{
  pkgs,
  lib,
  config,
  ...
}:

let
  # Only enable on NixOS desktop (not WSL)
  isDesktop = !config.wsl.enable or false;
in
{
  config = lib.mkIf isDesktop {
    # Install xremap
    environment.systemPackages = [ pkgs.xremap ];

    # xremap config
    environment.etc."xremap/config.yml".text = ''
      # Vim-friendly: CapsLock to Escape (tap) / Ctrl (hold)
      modmap:
        - name: CapsLock to Ctrl/Escape
          remap:
            CapsLock:
              held: Ctrl_L
              alone: Escape
              alone_timeout_millis: 200
    '';

    # Systemd service for xremap
    systemd.services.xremap = {
      description = "xremap key remapper";
      wantedBy = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.xremap}/bin/xremap /etc/xremap/config.yml";
        Restart = "always";
        RestartSec = 3;
      };
    };

    # Allow xremap to access input devices
    users.groups.input.members = [ "anko" ];
    services.udev.extraRules = ''
      KERNEL=="uinput", GROUP="input", MODE="0660"
    '';
  };
}
