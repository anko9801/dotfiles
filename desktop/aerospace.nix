{
  config,
  lib,
  pkgs,
  ...
}:

let
  c = config.home-manager.users.${config.system.primaryUser}.theme.colors;

  # Hex color to 0xAARRGGBB format for borders/sketchybar (strip # prefix, add 0xff)
  toArgb = hex: "0xff${builtins.substring 1 6 hex}";

  workspaceKeys = builtins.fromJSON (builtins.readFile ./workspaces.json);
  workspaceNotifier = import ./sketchybar/notifier.nix { inherit pkgs; };
  workspaceBindings = lib.concatMapStringsSep "\n" (workspace: ''
    alt-${lib.toLower workspace} = 'workspace ${workspace}'
    alt-shift-${lib.toLower workspace} = ['move-node-to-workspace ${workspace}', 'exec-and-forget sketchybar --trigger aerospace_windows_change']
  '') workspaceKeys;

  # Apps that should float by default
  floatingApps = [
    "com.apple.systempreferences"
    "com.apple.calculator"
    "com.apple.finder"
    "com.apple.ActivityMonitor"
    "com.agilebits.onepassword7"
    "com.1password.1password"
    "com.raycast.macos"
    "com.apple.archiveutility"
    "com.apple.Dictionary"
    "com.apple.systeminfo"
    "com.apple.AppStore"
    "com.macpaw.CleanMyMac4"
    "com.logi.cp-dev-mgr.service"
  ];

  floatingRules = lib.concatMapStrings (app: ''

    [[on-window-detected]]
    if.app-id = '${app}'
    run = 'layout floating'
  '') floatingApps;

  # Auto-assign apps to workspaces (Arc excluded — opens in current workspace)
  autoAssignApps = [
    {
      appId = "com.mitchellh.ghostty";
      workspace = "2";
    } # Ghostty
    {
      appId = "com.hnc.Discord";
      workspace = "D";
    } # Discord
    {
      appId = "com.spotify.client";
      workspace = "S";
    } # Spotify
    {
      appId = "notion.id";
      workspace = "A";
    } # Notion
    {
      appId = "com.tinyspeck.slackmacgap";
      workspace = "Q";
    } # Slack
    {
      appId = "com.cmuxterm.app";
      workspace = "Z";
    } # cmux
    {
      appId = "com.anthropic.claudefordesktop";
      workspace = "C";
    } # Claude
  ];

  autoAssignRules = lib.concatMapStrings (app: ''

    [[on-window-detected]]
    if.app-id = '${app.appId}'
    run = 'move-node-to-workspace ${app.workspace}'
  '') autoAssignApps;

in
{
  home-manager.users.${config.system.primaryUser} = {
    home.file = {
      ".config/aerospace/aerospace.toml".text = ''
        # AeroSpace - tiling window manager for macOS
        # https://github.com/nikitabobko/AeroSpace

        config-version = 2
        persistent-workspaces = ${builtins.toJSON workspaceKeys}

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

        # Notify at the committed workspace change without starting a shell.
        exec-on-workspace-change = ["${workspaceNotifier}"]

        # Gaps and padding
        [gaps]
        inner.horizontal = 4
        inner.vertical = 4
        outer.left = 0
        outer.bottom = 0
        outer.top = 0
        outer.right = 0

        [mode.main.binding]
        # Window focus (alt + vim keys)
        alt-h = 'focus left'
        alt-j = 'focus down'
        alt-k = 'focus up'
        alt-l = 'focus right'

        # Move windows (alt + shift + vim keys)
        alt-shift-h = 'move left'
        alt-shift-j = 'move down'
        alt-shift-k = 'move up'
        alt-shift-l = 'move right'

        # Workspace focus and movement share their order with SketchyBar.
        ${workspaceBindings}

        # Workspace navigation
        alt-leftSquareBracket = 'workspace prev'
        alt-rightSquareBracket = 'workspace next'
        alt-tab = 'workspace-back-and-forth'

        # Layout controls
        alt-f = 'fullscreen'
        alt-slash = 'layout tiles horizontal vertical'
        alt-comma = 'layout accordion horizontal vertical'

        # Resize mode
        alt-r = 'mode resize'

        # Service mode
        alt-shift-semicolon = 'mode service'

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
        c = ['reload-config', 'exec-and-forget sketchybar --reload', 'mode main']
        f = ['layout floating tiling', 'mode main']
        b = ['balance-sizes', 'mode main']
        backspace = ['close-all-windows-but-current', 'mode main']
        enter = 'mode main'
        esc = 'mode main'

        # Excluded applications (floating by default)
        ${floatingRules}

        # Auto-assign apps to workspaces
        ${autoAssignRules}
      '';

      ".config/borders/bordersrc" = {
        executable = true;
        text = ''
          #!/bin/bash

          options=(
            style=round
            width=6.0
            hidpi=off
            ax_focus=off
            active_color=${toArgb c.blue}
            inactive_color=0x00000000
          )

          borders "''${options[@]}"
        '';
      };

      ".local/bin/secure-input-status" = {
        executable = true;
        text = ''
          #!/bin/bash

          secure_input_pid=$(
            /usr/sbin/ioreg -l -w 0 -c IOHIDSystem \
              | /usr/bin/grep -Eo 'kCGSSessionSecureInputPID"=[0-9]+' \
              | /usr/bin/head -n 1 \
              | /usr/bin/sed 's/.*=//'
          )

          if [[ -z "$secure_input_pid" ]]; then
            echo "Secure Input is disabled."
            exit 0
          fi

          process_name=$(/bin/ps -p "$secure_input_pid" -o comm= 2>/dev/null || true)
          if [[ -n "$process_name" ]]; then
            echo "Secure Input is enabled; macOS reports PID $secure_input_pid ($process_name)."
            echo "The reported process may only have been frontmost when the lock screen leaked Secure Input."
            echo "Close any focused password field; if it remains stuck, log out or restart macOS."
          else
            echo "Secure Input is still registered to exited PID $secure_input_pid."
            echo "This is consistent with a leaked macOS Secure Input state; log out or restart macOS."
          fi
        '';
      };
    };
  };
}
