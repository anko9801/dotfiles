local app_icons = require("helpers.app_icons")

sbar.add("event", "aerospace_workspace_change")

local function get_app_display(sid)
  local handle = io.popen(
    "aerospace list-windows --workspace '" .. sid .. "' --format '%{app-name}' 2>/dev/null | sort -u"
  )
  local result = handle:read("*a")
  handle:close()

  local icon_line = ""
  local name_line = ""
  for app in result:gmatch("[^\n]+") do
    local icon = app_icons[app]
    if icon then
      icon_line = icon_line .. icon .. " "
    else
      name_line = name_line .. app .. " "
    end
  end
  return icon_line, name_line
end

local function update_space(space, sid, color, focused_workspace)
  sbar.exec(
    "aerospace list-windows --workspace '" .. sid .. "' --format '%{app-name}' 2>/dev/null | sort -u",
    function(result)
      local icon_line = ""
      local name_line = ""
      for app in result:gmatch("[^\n]+") do
        local icon = app_icons[app]
        if icon then
          icon_line = icon_line .. icon .. " "
        else
          name_line = name_line .. app .. " "
        end
      end

      local disp = sid
      if name_line ~= "" then
        disp = sid .. " " .. name_line
      end

      local has_windows = icon_line ~= "" or name_line ~= ""
      local is_focused = focused_workspace == sid

      if is_focused then
        space:set({
          drawing = true,
          icon = { string = disp, color = colors.black },
          label = { string = icon_line, color = colors.black },
          background = { drawing = true, color = color },
        })
      elseif has_windows then
        space:set({
          drawing = true,
          icon = { string = disp, color = color },
          label = { string = icon_line, color = color },
          background = { drawing = false },
        })
      else
        space:set({ drawing = false })
      end
    end
  )
end

-- Wait for AeroSpace
os.execute("while ! aerospace list-workspaces --all &>/dev/null; do sleep 0.5; done")

local handle = io.popen("aerospace list-workspaces --all")
local ws_result = handle:read("*a")
handle:close()

local focused_handle = io.popen("aerospace list-workspaces --focused 2>/dev/null")
local focused = focused_handle:read("*a"):gsub("%s+$", "")
focused_handle:close()

local spaces = {}
local i = 0
for sid in ws_result:gmatch("%S+") do
  local color = settings.space_colors[(i % #settings.space_colors) + 1]
  i = i + 1

  local icon_line, name_line = get_app_display(sid)
  local display_icon = sid
  if name_line ~= "" then
    display_icon = sid .. " " .. name_line
  end

  local has_windows = icon_line ~= "" or name_line ~= ""
  local is_focused = sid == focused

  local space = sbar.add("item", "space." .. sid, {
    position = "left",
    drawing = has_windows or is_focused,
    icon = {
      string = display_icon,
      color = is_focused and colors.black or color,
      font = settings.font.icon,
      padding_left = 8,
      padding_right = 4,
    },
    label = {
      string = icon_line,
      color = is_focused and colors.black or color,
      font = settings.font.app,
    },
    background = {
      drawing = is_focused,
      color = is_focused and color or colors.surface,
      border_color = color,
      corner_radius = 8,
      height = 28,
    },
  })

  spaces[sid] = { item = space, color = color }

  space:subscribe("aerospace_workspace_change", function(env)
    update_space(space, sid, color, env.FOCUSED_WORKSPACE)
  end)

  space:subscribe("mouse.clicked", function()
    sbar.exec("aerospace workspace " .. sid)
  end)
end
