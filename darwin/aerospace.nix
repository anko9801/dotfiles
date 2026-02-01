{ config, ... }:

{
  # AeroSpace configuration (TOML format)
  # Installed via Homebrew cask
  home-manager.users.${config.system.primaryUser}.home.file.".config/aerospace/aerospace.toml".text =
    ''
      # AeroSpace - tiling window manager for macOS
      # https://github.com/nikitabobko/AeroSpace

      # Start at login
      start-at-login = true

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
      outer.top = 12
      outer.right = 12

      # ==============================================================================
      # Main mode keybindings
      # Using Cmd (Super) for WM layer - avoids conflicts with terminal/editor
      # ==============================================================================
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
}
