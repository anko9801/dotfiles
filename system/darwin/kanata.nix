# Kanata - Cross-platform key remapper for macOS
# https://github.com/jtroo/kanata
# Requires Karabiner-DriverKit for virtual keyboard support
#
# Manual setup required after first install:
# 1. System Settings → Privacy & Security → Input Monitoring → add kanata
# 2. System Settings → Keyboard → Select "Karabiner DriverKit VirtualHIDKeyboard"
{ config, ... }:

let
  user = config.system.primaryUser;
in
{
  # Launchd daemon for Kanata
  launchd.daemons.kanata = {
    serviceConfig = {
      Label = "com.kanata.daemon";
      ProgramArguments = [
        "/opt/homebrew/bin/kanata"
        "-c"
        "/Users/${user}/.config/kanata/kanata.kbd"
      ];
      RunAtLoad = true;
      KeepAlive = true;
      StandardOutPath = "/tmp/kanata.out.log";
      StandardErrorPath = "/tmp/kanata.err.log";
    };
  };
}
