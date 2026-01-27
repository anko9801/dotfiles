_:

{
  # AeroSpace configuration (TOML format)
  # Installed via Homebrew cask
  home-manager.users.anko.home.file.".config/aerospace/aerospace.toml".text = ''
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

    # Main mode keybindings
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

    # Workspace focus (alt + number)
    alt-1 = 'workspace 1'
    alt-2 = 'workspace 2'
    alt-3 = 'workspace 3'
    alt-4 = 'workspace 4'
    alt-5 = 'workspace 5'
    alt-6 = 'workspace 6'
    alt-7 = 'workspace 7'
    alt-8 = 'workspace 8'
    alt-9 = 'workspace 9'

    # Move window to workspace (alt + shift + number)
    alt-shift-1 = 'move-node-to-workspace 1'
    alt-shift-2 = 'move-node-to-workspace 2'
    alt-shift-3 = 'move-node-to-workspace 3'
    alt-shift-4 = 'move-node-to-workspace 4'
    alt-shift-5 = 'move-node-to-workspace 5'
    alt-shift-6 = 'move-node-to-workspace 6'
    alt-shift-7 = 'move-node-to-workspace 7'
    alt-shift-8 = 'move-node-to-workspace 8'
    alt-shift-9 = 'move-node-to-workspace 9'

    # Layout controls
    alt-f = 'fullscreen'
    alt-t = 'layout floating tiling'
    alt-e = 'layout tiles horizontal vertical'

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
