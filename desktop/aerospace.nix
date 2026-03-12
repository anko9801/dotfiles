{ config, lib, ... }:

let
  c = config.home-manager.users.${config.system.primaryUser}.theme.colors;

  # Hex color to 0xAARRGGBB format for borders/sketchybar (strip # prefix, add 0xff)
  toArgb = hex: "0xff${builtins.substring 1 6 hex}";

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

      # Notify SketchyBar on workspace change
      exec-on-workspace-change = [
        '/bin/bash', '-c',
        'sketchybar --trigger aerospace_workspace_change FOCUSED_WORKSPACE=$AEROSPACE_FOCUSED_WORKSPACE',
      ]

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

      # Workspace focus (alt + key)
      alt-1 = 'workspace 1'
      alt-2 = 'workspace 2'
      alt-3 = 'workspace 3'
      alt-4 = 'workspace 4'
      alt-5 = 'workspace 5'
      alt-6 = 'workspace 6'
      alt-7 = 'workspace 7'
      alt-8 = 'workspace 8'
      alt-9 = 'workspace 9'
      alt-0 = 'workspace 0'
      alt-q = 'workspace Q'
      alt-w = 'workspace W'
      alt-e = 'workspace E'
      alt-t = 'workspace T'
      alt-y = 'workspace Y'
      alt-u = 'workspace U'
      alt-i = 'workspace I'
      alt-o = 'workspace O'
      alt-p = 'workspace P'
      alt-a = 'workspace A'
      alt-s = 'workspace S'
      alt-d = 'workspace D'
      alt-g = 'workspace G'
      alt-v = 'workspace V'
      alt-b = 'workspace B'
      alt-n = 'workspace N'
      alt-m = 'workspace M'
      alt-z = 'workspace Z'
      alt-x = 'workspace X'
      alt-c = 'workspace C'

      # Move window to workspace (alt + shift + key)
      alt-shift-1 = 'move-node-to-workspace 1'
      alt-shift-2 = 'move-node-to-workspace 2'
      alt-shift-3 = 'move-node-to-workspace 3'
      alt-shift-4 = 'move-node-to-workspace 4'
      alt-shift-5 = 'move-node-to-workspace 5'
      alt-shift-6 = 'move-node-to-workspace 6'
      alt-shift-7 = 'move-node-to-workspace 7'
      alt-shift-8 = 'move-node-to-workspace 8'
      alt-shift-9 = 'move-node-to-workspace 9'
      alt-shift-0 = 'move-node-to-workspace 0'
      alt-shift-q = 'move-node-to-workspace Q'
      alt-shift-w = 'move-node-to-workspace W'
      alt-shift-e = 'move-node-to-workspace E'
      alt-shift-t = 'move-node-to-workspace T'
      alt-shift-y = 'move-node-to-workspace Y'
      alt-shift-u = 'move-node-to-workspace U'
      alt-shift-i = 'move-node-to-workspace I'
      alt-shift-o = 'move-node-to-workspace O'
      alt-shift-p = 'move-node-to-workspace P'
      alt-shift-a = 'move-node-to-workspace A'
      alt-shift-s = 'move-node-to-workspace S'
      alt-shift-d = 'move-node-to-workspace D'
      alt-shift-g = 'move-node-to-workspace G'
      alt-shift-v = 'move-node-to-workspace V'
      alt-shift-b = 'move-node-to-workspace B'
      alt-shift-n = 'move-node-to-workspace N'
      alt-shift-m = 'move-node-to-workspace M'
      alt-shift-z = 'move-node-to-workspace Z'
      alt-shift-x = 'move-node-to-workspace X'
      alt-shift-c = 'move-node-to-workspace C'

      # Workspace navigation
      alt-leftSquareBracket = 'workspace prev'
      alt-rightSquareBracket = 'workspace next'

      # Layout controls
      alt-f = 'fullscreen'

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
          hidpi=on
          active_color=${toArgb c.blue}
          inactive_color=0x00000000
        )

        borders "''${options[@]}"
      '';
    };

  };
}
