local app_icons = require("helpers.app_icons")

sbar.add("event", "aerospace_workspace_change")

local function get_app_display(sid)
  local handle = io.popen(
    "aerospace list-windows --workspace '" .. sid .. "' --format '%{app-name}' 2>/dev/null | sort -u"
  )
  if not handle then return "", "" end
  local result = handle:read("*a") or ""
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
  return icon_line:gsub("%s+$", ""), name_line:gsub("%s+$", "")
end

local function set_focused(space, is_focused, has_windows)
  space:set({
    drawing = has_windows,
    icon = { highlight = is_focused },
    label = { highlight = is_focused },
    background = { color = is_focused and colors.bar.bg or colors.transparent },
  })
end

-- Non-blocking: check if aerospace is available, skip space creation if not
local handle = io.popen("aerospace list-workspaces --all 2>/dev/null")
local ws_result = handle and handle:read("*a") or ""
if handle then handle:close() end

if ws_result == "" then return end

local focused_handle = io.popen("aerospace list-workspaces --focused 2>/dev/null")
local focused = focused_handle and focused_handle:read("*a") or ""
if focused_handle then focused_handle:close() end
focused = focused:gsub("%s+$", "")

local keyboard_order = {
  "1", "2", "3", "4", "5", "6", "7", "8", "9", "0",
  "Q", "W", "E", "T", "Y", "U", "I", "O", "P",
  "A", "S", "D", "G", "V", "B", "N", "M",
  "Z", "X", "C",
}

local ws_set = {}
for sid in ws_result:gmatch("%S+") do
  ws_set[sid] = true
end

local spaces = {}
local i = 0
for _, sid in ipairs(keyboard_order) do
  if not ws_set[sid] then goto continue end
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
    updates = true,
    drawing = has_windows,
    icon = {
      font = { family = settings.font.numbers },
      string = display_icon,
      padding_left = 8,
      padding_right = icon_line ~= "" and 4 or 8,
      color = color,
      highlight_color = color,
      highlight = is_focused,
    },
    label = {
      string = icon_line,
      drawing = icon_line ~= "",
      padding_right = 8,
      color = color,
      highlight_color = color,
      font = "sketchybar-app-font:Regular:14.0",
      y_offset = -1,
      highlight = is_focused,
    },
    padding_right = 2,
    padding_left = 2,
    background = {
      color = is_focused and colors.bar.bg or colors.transparent,
      border_width = 0,
      height = 26,
    },
  })

  spaces[sid] = { item = space, color = color, has_windows = has_windows }

  space:subscribe("aerospace_workspace_change", function(env)
    local icon_line, name_line = get_app_display(sid)
    local display_icon = sid
    if name_line ~= "" then
      display_icon = sid .. " " .. name_line
    end
    local has_windows = icon_line ~= "" or name_line ~= ""
    spaces[sid].has_windows = has_windows

    space:set({
      icon = {
        string = display_icon,
        padding_right = icon_line ~= "" and 4 or 8,
      },
      label = {
        string = icon_line,
        drawing = icon_line ~= "",
      },
    })
    set_focused(space, env.FOCUSED_WORKSPACE == sid, has_windows)
  end)

  space:subscribe("mouse.clicked", function()
    sbar.exec("aerospace workspace " .. sid)
  end)
  ::continue::
end
