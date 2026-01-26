{
  config,
  pkgs,
  lib,
  ...
}:

{
  # skhd - hotkey daemon for macOS
  services.skhd = {
    enable = true;

    skhdConfig = ''
      # Window focus (alt + vim keys)
      alt - h : yabai -m window --focus west
      alt - j : yabai -m window --focus south
      alt - k : yabai -m window --focus north
      alt - l : yabai -m window --focus east

      # Window swap (shift + alt + vim keys)
      shift + alt - h : yabai -m window --swap west
      shift + alt - j : yabai -m window --swap south
      shift + alt - k : yabai -m window --swap north
      shift + alt - l : yabai -m window --swap east

      # Window warp (shift + cmd + vim keys)
      shift + cmd - h : yabai -m window --warp west
      shift + cmd - j : yabai -m window --warp south
      shift + cmd - k : yabai -m window --warp north
      shift + cmd - l : yabai -m window --warp east

      # Balance windows
      shift + alt - 0 : yabai -m space --balance

      # Create desktop and follow focus
      shift + cmd - n : yabai -m space --create && \
                        index="$(yabai -m query --spaces --display | jq 'map(select(."is-native-fullscreen" == false))[-1].index')" && \
                        yabai -m space --focus "''${index}"

      # Destroy desktop
      cmd + alt - w : yabai -m space --destroy

      # Focus desktop (cmd + number)
      cmd - 1 : yabai -m space --focus 1
      cmd - 2 : yabai -m space --focus 2
      cmd - 3 : yabai -m space --focus 3
      cmd - 4 : yabai -m space --focus 4
      cmd - 5 : yabai -m space --focus 5
      cmd - 6 : yabai -m space --focus 6
      cmd - 7 : yabai -m space --focus 7
      cmd - 8 : yabai -m space --focus 8
      cmd - 9 : yabai -m space --focus 9

      # Send window to desktop and follow focus
      shift + cmd - 1 : yabai -m window --space 1; yabai -m space --focus 1
      shift + cmd - 2 : yabai -m window --space 2; yabai -m space --focus 2
      shift + cmd - 3 : yabai -m window --space 3; yabai -m space --focus 3
      shift + cmd - 4 : yabai -m window --space 4; yabai -m space --focus 4
      shift + cmd - 5 : yabai -m window --space 5; yabai -m space --focus 5
      shift + cmd - 6 : yabai -m window --space 6; yabai -m space --focus 6
      shift + cmd - 7 : yabai -m window --space 7; yabai -m space --focus 7
      shift + cmd - 8 : yabai -m window --space 8; yabai -m space --focus 8
      shift + cmd - 9 : yabai -m window --space 9; yabai -m space --focus 9

      # Toggle fullscreen
      alt - f : yabai -m window --toggle zoom-fullscreen

      # Toggle split type
      alt - e : yabai -m window --toggle split

      # Float/unfloat window and center
      alt - t : yabai -m window --toggle float; yabai -m window --grid 4:4:1:1:2:2
    '';
  };
}
