{ config, ... }:

{
  home-manager.users.${config.system.primaryUser}.home.file = {
    ".config/aerospace/aerospace.toml".text = ''
      # AeroSpace - tiling window manager for macOS
      # https://github.com/nikitabobko/AeroSpace

      # Start at login
      start-at-login = true

      # Start JankyBorders and SketchyBar with AeroSpace
      after-startup-command = [
        'exec-and-forget borders',
        'exec-and-forget sketchybar',
      ]

      # Normalizations
      enable-normalization-flatten-containers = true
      enable-normalization-opposite-orientation-for-nested-containers = true

      # Mouse settings
      on-focused-monitor-changed = ['move-mouse monitor-lazy-center']

      # Gaps and padding
      [gaps]
      inner.horizontal = 6
      inner.vertical = 6
      outer.left = 12
      outer.bottom = 12
      outer.top = 40  # Space for SketchyBar
      outer.right = 12

      [mode.main.binding]
      # Window focus (cmd + vim keys)
      cmd-h = 'focus left'
      cmd-j = 'focus down'
      cmd-k = 'focus up'
      cmd-l = 'focus right'

      # Move windows (cmd + shift + vim keys)
      cmd-shift-h = 'move left'
      cmd-shift-j = 'move down'
      cmd-shift-k = 'move up'
      cmd-shift-l = 'move right'

      # Workspace focus (cmd + number)
      cmd-1 = 'workspace 1'
      cmd-2 = 'workspace 2'
      cmd-3 = 'workspace 3'
      cmd-4 = 'workspace 4'
      cmd-5 = 'workspace 5'
      cmd-6 = 'workspace 6'
      cmd-7 = 'workspace 7'
      cmd-8 = 'workspace 8'
      cmd-9 = 'workspace 9'

      # Move window to workspace (cmd + shift + number)
      cmd-shift-1 = 'move-node-to-workspace 1'
      cmd-shift-2 = 'move-node-to-workspace 2'
      cmd-shift-3 = 'move-node-to-workspace 3'
      cmd-shift-4 = 'move-node-to-workspace 4'
      cmd-shift-5 = 'move-node-to-workspace 5'
      cmd-shift-6 = 'move-node-to-workspace 6'
      cmd-shift-7 = 'move-node-to-workspace 7'
      cmd-shift-8 = 'move-node-to-workspace 8'
      cmd-shift-9 = 'move-node-to-workspace 9'

      # Layout controls
      cmd-f = 'fullscreen'
      cmd-t = 'layout floating tiling'
      cmd-e = 'layout tiles horizontal vertical'

      # Balance windows
      cmd-shift-0 = 'balance-sizes'

      # Resize mode
      cmd-r = 'mode resize'

      # Service mode
      cmd-shift-semicolon = 'mode service'

      # Resize mode keybindings
      [mode.resize.binding]
      h = 'resize width -50'
      j = 'resize height +50'
      k = 'resize height -50'
      l = 'resize width +50'
      enter = 'mode main'
      esc = 'mode main'

      # Service mode keybindings
      [mode.service.binding]
      r = ['flatten-workspace-tree', 'mode main']
      f = ['layout floating tiling', 'mode main']
      backspace = ['close-all-windows-but-current', 'mode main']
      enter = 'mode main'
      esc = 'mode main'

      # Excluded applications (floating by default)
      [[on-window-detected]]
      if.app-id = 'com.apple.systempreferences'
      run = 'layout floating'

      [[on-window-detected]]
      if.app-id = 'com.apple.calculator'
      run = 'layout floating'

      [[on-window-detected]]
      if.app-id = 'com.apple.finder'
      run = 'layout floating'

      [[on-window-detected]]
      if.app-id = 'com.apple.ActivityMonitor'
      run = 'layout floating'

      [[on-window-detected]]
      if.app-id = 'com.agilebits.onepassword7'
      run = 'layout floating'

      [[on-window-detected]]
      if.app-id = 'com.1password.1password'
      run = 'layout floating'

      [[on-window-detected]]
      if.app-id = 'com.raycast.macos'
      run = 'layout floating'

      [[on-window-detected]]
      if.app-id = 'com.apple.archiveutility'
      run = 'layout floating'

      [[on-window-detected]]
      if.app-id = 'com.apple.Dictionary'
      run = 'layout floating'

      [[on-window-detected]]
      if.app-id = 'com.apple.systeminfo'
      run = 'layout floating'

      [[on-window-detected]]
      if.app-id = 'com.apple.AppStore'
      run = 'layout floating'

      [[on-window-detected]]
      if.app-id = 'com.macpaw.CleanMyMac4'
      run = 'layout floating'

      [[on-window-detected]]
      if.app-id = 'com.logi.cp-dev-mgr.service'
      run = 'layout floating'
    '';

    ".config/borders/bordersrc" = {
      executable = true;
      text = ''
        #!/bin/bash

        options=(
          style=round
          width=6.0
          hidpi=on
          active_color=0xff7aa2f7   # Tokyo Night blue
          inactive_color=0xff565f89 # Tokyo Night comment
        )

        borders "''${options[@]}"
      '';
    };

    ".config/sketchybar/sketchybarrc" = {
      executable = true;
      text = ''
        #!/bin/bash

        # Tokyo Night color palette
        export BLACK=0xff1a1b26
        export WHITE=0xffc0caf5
        export RED=0xfff7768e
        export GREEN=0xff9ece6a
        export BLUE=0xff7aa2f7
        export YELLOW=0xffe0af68
        export ORANGE=0xffff9e64
        export MAGENTA=0xffbb9af7
        export GREY=0xff565f89
        export TRANSPARENT=0x00000000

        # Bar appearance
        sketchybar --bar \
          height=32 \
          blur_radius=30 \
          position=top \
          sticky=on \
          padding_left=10 \
          padding_right=10 \
          color=$BLACK

        # Default item settings
        sketchybar --default \
          icon.font="JetBrainsMono Nerd Font:Bold:14.0" \
          icon.color=$WHITE \
          label.font="JetBrainsMono Nerd Font:Bold:14.0" \
          label.color=$WHITE \
          background.color=$GREY \
          background.corner_radius=5 \
          background.height=24 \
          padding_left=5 \
          padding_right=5 \
          label.padding_left=4 \
          label.padding_right=4 \
          icon.padding_left=4 \
          icon.padding_right=4

        # AeroSpace workspace indicators
        for sid in $(aerospace list-workspaces --all); do
          sketchybar --add item space.$sid left \
            --subscribe space.$sid aerospace_workspace_change \
            --set space.$sid \
              background.color=$GREY \
              background.corner_radius=5 \
              background.height=20 \
              background.drawing=off \
              label="$sid" \
              click_script="aerospace workspace $sid" \
              script="$CONFIG_DIR/plugins/aerospace.sh $sid"
        done

        # Front app name
        sketchybar --add item front_app left \
          --set front_app \
            icon.drawing=off \
            script="sketchybar --set \$NAME label=\"\$INFO\"" \
          --subscribe front_app front_app_switched

        # Clock
        sketchybar --add item clock right \
          --set clock \
            update_freq=10 \
            script="sketchybar --set \$NAME label=\"\$(date '+%H:%M')\""

        # Battery
        sketchybar --add item battery right \
          --set battery \
            update_freq=120 \
            script="sketchybar --set \$NAME label=\"\$(pmset -g batt | grep -Eo '\d+%')\""

        # Initialize
        sketchybar --update
      '';
    };

    # AeroSpace workspace change script for SketchyBar
    ".config/sketchybar/plugins/aerospace.sh" = {
      executable = true;
      text = ''
        #!/bin/bash

        if [ "$1" = "$FOCUSED_WORKSPACE" ]; then
          sketchybar --set $NAME background.drawing=on
        else
          sketchybar --set $NAME background.drawing=off
        fi
      '';
    };
  };
}
