local act = wezterm.action
local config = wezterm.config_builder()

-- Performance
config.front_end = "WebGpu"
config.max_fps = 120
config.animation_fps = 120
config.webgpu_power_preference = "HighPerformance"

-- Window
config.window_decorations = "RESIZE"
config.window_close_confirmation = "NeverPrompt"
config.adjust_window_size_when_changing_font_size = false
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = false
config.window_padding = { left = 2, right = 2, top = 2, bottom = 0 }
config.hide_mouse_cursor_when_typing = true

-- General
config.scrollback_lines = 20000
config.automatically_reload_config = true
config.audible_bell = "Disabled"
config.default_cursor_style = "BlinkingBlock"
config.cursor_blink_rate = 650

-- Font (primary set by Stylix, add Nerd Font + emoji fallback)
config.font = wezterm.font_with_fallback({
  "Moralerspace Neon",
  "Symbols Nerd Font Mono",
  "Noto Color Emoji",
})
config.font_size = 14.0

-- Opacity
config.window_background_opacity = 0.95
config.macos_window_background_blur = 30

-- Inactive pane dimming
config.inactive_pane_hsb = { saturation = 0.9, brightness = 0.8 }

-- Shell process skip confirmation
config.skip_close_confirmation_for_processes_named = {
  "bash", "sh", "zsh", "fish", "nu",
}

-- Leader key: Ctrl-q (matching tmux/zellij/ghostty)
config.leader = { key = "q", mods = "CTRL", timeout_milliseconds = 1000 }

config.keys = {
  -- Send literal Ctrl-q
  { key = "q", mods = "LEADER|CTRL", action = act.SendKey({ key = "q", mods = "CTRL" }) },

  -- Splits
  { key = "-", mods = "LEADER", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
  { key = "\\", mods = "LEADER|SHIFT", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },

  -- Pane navigation (vim-style)
  { key = "h", mods = "LEADER", action = act.ActivatePaneDirection("Left") },
  { key = "j", mods = "LEADER", action = act.ActivatePaneDirection("Down") },
  { key = "k", mods = "LEADER", action = act.ActivatePaneDirection("Up") },
  { key = "l", mods = "LEADER", action = act.ActivatePaneDirection("Right") },

  -- Pane resize
  { key = "H", mods = "LEADER|SHIFT", action = act.AdjustPaneSize({ "Left", 5 }) },
  { key = "J", mods = "LEADER|SHIFT", action = act.AdjustPaneSize({ "Down", 5 }) },
  { key = "K", mods = "LEADER|SHIFT", action = act.AdjustPaneSize({ "Up", 5 }) },
  { key = "L", mods = "LEADER|SHIFT", action = act.AdjustPaneSize({ "Right", 5 }) },

  -- Pane management
  { key = "z", mods = "LEADER", action = act.TogglePaneZoomState },
  { key = "x", mods = "LEADER", action = act.CloseCurrentPane({ confirm = false }) },
  { key = "Space", mods = "LEADER", action = act.RotatePanes("Clockwise") },

  -- Tabs
  { key = "c", mods = "LEADER", action = act.SpawnTab("CurrentPaneDomain") },
  { key = "n", mods = "LEADER", action = act.ActivateTabRelative(1) },
  { key = "p", mods = "LEADER", action = act.ActivateTabRelative(-1) },

  -- Copy mode
  { key = "Enter", mods = "LEADER", action = act.ActivateCopyMode },

  -- Quick splits (no prefix, matching Ghostty super+d)
  { key = "d", mods = "SUPER", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
  { key = "d", mods = "SUPER|SHIFT", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
}

-- Tab number shortcuts: Leader + 1-9
for i = 1, 9 do
  table.insert(config.keys, {
    key = tostring(i), mods = "LEADER", action = act.ActivateTab(i - 1),
  })
end

-- Tab title: index + cwd basename
wezterm.on("format-tab-title", function(tab)
  local cwd = tab.active_pane.current_working_dir
  local title = cwd and cwd.file_path:match("([^/]+)$") or tab.active_pane.title
  return string.format(" %d: %s ", tab.tab_index + 1, title)
end)

-- Right status: workspace + time
wezterm.on("update-right-status", function(window)
  window:set_right_status(wezterm.format({
    { Text = string.format(" %s | %s ", window:active_workspace(), wezterm.strftime("%H:%M")) },
  }))
end)

return config
