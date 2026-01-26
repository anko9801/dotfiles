{
  config,
  pkgs,
  lib,
  ...
}:

{
  # Yabai - tiling window manager for macOS
  services.yabai = {
    enable = true;
    enableScriptingAddition = true;

    config = {
      # Mouse settings
      mouse_follows_focus = "off";
      focus_follows_mouse = "off";
      mouse_modifier = "fn";
      mouse_action1 = "move";
      mouse_action2 = "resize";
      mouse_drop_action = "swap";

      # Window settings
      window_origin_display = "default";
      window_placement = "second_child";
      window_zoom_persist = "on";
      window_shadow = "on";
      window_animation_duration = "0.0";
      window_opacity = "off";
      active_window_opacity = "1.0";
      normal_window_opacity = "0.95";

      # Layout settings
      layout = "bsp";
      split_ratio = "0.50";
      split_type = "auto";
      auto_balance = "off";

      # Padding and gaps
      top_padding = 12;
      bottom_padding = 12;
      left_padding = 12;
      right_padding = 12;
      window_gap = 6;

      # Visual
      insert_feedback_color = "0xffd75f5f";
    };

    extraConfig = ''
      # Excluded applications
      yabai -m rule --add app="^System Settings$" manage=off
      yabai -m rule --add app="^Calculator$" manage=off
      yabai -m rule --add app="^Finder$" manage=off
      yabai -m rule --add app="^Archive Utility$" manage=off
      yabai -m rule --add app="^Activity Monitor$" manage=off
      yabai -m rule --add app="^Dictionary$" manage=off
      yabai -m rule --add app="^System Information$" manage=off
      yabai -m rule --add app="^1Password$" manage=off
      yabai -m rule --add app="^App Store$" manage=off
      yabai -m rule --add app="^Raycast$" manage=off
      yabai -m rule --add app="^CleanMyMac X$" manage=off
      yabai -m rule --add app="^Logi Options$" manage=off

      echo "yabai configuration loaded.."
    '';
  };
}
