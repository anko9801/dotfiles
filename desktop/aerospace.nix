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

  # Auto-assign apps to workspaces
  autoAssignApps = [
    {
      appId = "company.thebrowser.Browser";
      workspace = "1";
    } # Arc
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
      appId = "us.zoom.xos";
      workspace = "Z";
    } # Zoom
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

      # Gaps and padding
      [gaps]
      inner.horizontal = 4
      inner.vertical = 4
      outer.left = 0
      outer.bottom = 0
      outer.top = -2
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
      # Row 1: numbers
      alt-1 = 'workspace 1'
      alt-2 = 'workspace 2'
      alt-3 = 'workspace 3'
      # Row 2: qwe
      alt-q = 'workspace Q'
      alt-w = 'workspace W'
      alt-e = 'workspace E'
      # Row 3: asd
      alt-a = 'workspace A'
      alt-s = 'workspace S'
      alt-d = 'workspace D'
      # Row 4: zxc
      alt-z = 'workspace Z'
      alt-x = 'workspace X'
      alt-c = 'workspace C'

      # Move window to workspace (alt + shift + key)
      alt-shift-1 = 'move-node-to-workspace 1'
      alt-shift-2 = 'move-node-to-workspace 2'
      alt-shift-3 = 'move-node-to-workspace 3'
      alt-shift-q = 'move-node-to-workspace Q'
      alt-shift-w = 'move-node-to-workspace W'
      alt-shift-e = 'move-node-to-workspace E'
      alt-shift-a = 'move-node-to-workspace A'
      alt-shift-s = 'move-node-to-workspace S'
      alt-shift-d = 'move-node-to-workspace D'
      alt-shift-z = 'move-node-to-workspace Z'
      alt-shift-x = 'move-node-to-workspace X'
      alt-shift-c = 'move-node-to-workspace C'

      # Workspace navigation
      alt-leftSquareBracket = 'workspace prev'
      alt-rightSquareBracket = 'workspace next'

      # Layout controls
      alt-f = 'fullscreen'
      alt-t = 'layout floating tiling'

      # Balance windows
      alt-shift-0 = 'balance-sizes'

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
