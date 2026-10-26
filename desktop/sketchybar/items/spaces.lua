local app_icons = require("helpers.app_icons")
local probe = require("helpers.probe")

sbar.add("event", "aerospace_workspace_change")
sbar.add("event", "aerospace_windows_change")

local keyboard_order = require("workspaces")

local spaces = {}
local focused = ""
local clock = require("processstamp")
local last_event_start = clock.birth()
local windows_current = false
for i, sid in ipairs(keyboard_order) do
  local color = settings.space_colors[((i - 1) % #settings.space_colors) + 1]
  local space = sbar.add("item", "space." .. sid, {
    position = "left",
    drawing = false,
    icon = {
      font = { family = settings.font.numbers },
      string = sid,
      padding_left = 8,
      padding_right = 8,
      color = color,
      highlight_color = color,
    },
    label = {
      string = "",
      drawing = false,
      padding_right = 8,
      color = color,
      highlight_color = color,
      font = "sketchybar-app-font:Regular:14.0",
      y_offset = -1,
    },
    padding_right = 2,
    padding_left = 2,
    background = {
      color = colors.transparent,
      border_width = 0,
      height = 26,
    },
  })
  spaces[sid] = { item = space, has_windows = false, apps = {} }
  space:subscribe("mouse.clicked", function()
    sbar.exec("aerospace workspace " .. sid)
  end)
end

local extra = sbar.add("item", "space.other", { position = "left", drawing = false, label = { drawing = false } })
local status = sbar.add("item", "space.status", { position = "left", drawing = true, icon = { string = "WS —", color = colors.grey }, label = { drawing = false } })
extra:subscribe("mouse.clicked", function()
  if focused ~= "" then sbar.exec("aerospace workspace " .. require("helpers.shell").quote(focused)) end
end)

local extra_focus, status_drawing
local function render_focus()
  for sid, space in pairs(spaces) do
    local selected = sid == focused
    local drawing = space.has_windows or selected
    if space.selected ~= selected or space.drawing ~= drawing then
      space.item:set({
        drawing = drawing,
        icon = { highlight = selected },
        label = { highlight = selected },
        background = { color = selected and colors.bar.bg or colors.transparent },
      })
      space.selected, space.drawing = selected, drawing
    end
  end
  if extra_focus ~= focused then
    extra:set({ drawing = focused ~= "" and spaces[focused] == nil, icon = { string = focused } })
    extra_focus = focused
  end
  if status_drawing ~= (focused == "") then
    status_drawing = focused == ""
    status:set({ drawing = status_drawing })
  end
end

local function render_windows(windows)
  local apps = {}
  for _, window in ipairs(windows) do
    local sid, app = window.workspace, window["app-name"]
    if spaces[sid] and type(app) == "string" and app ~= "" then
      apps[sid] = apps[sid] or {}
      apps[sid][app] = true
    end
  end
  for sid, space in pairs(spaces) do
    space.apps = apps[sid] or {}
    local names, icons, labels = {}, {}, {}
    for app in pairs(space.apps) do names[#names + 1] = app end
    table.sort(names)
    local signature = table.concat(names, "\0")
    if signature ~= space.signature then
      for _, app in ipairs(names) do
        local target = app_icons[app] and icons or labels
        target[#target + 1] = app_icons[app] or app
      end
      space.has_windows = #names > 0
      space.item:set({
        icon = {
          string = sid .. (#labels > 0 and " " .. table.concat(labels, " ") or ""),
          padding_right = #icons > 0 and 4 or 8,
        },
        label = { string = table.concat(icons, " "), drawing = #icons > 0 },
      })
      space.signature = signature
    end
  end
  render_focus()
end

local window_request = probe.new({
  command = "aerospace list-windows --all --format '%{workspace}%{app-name}' --json",
  max_age = 25,
  unavailable = function()
    windows_current = false
    for sid, space in pairs(spaces) do
      space.has_windows, space.signature, space.apps = false, nil, {}
      space.item:set({ icon = { string = sid .. (sid == focused and " —" or "") }, label = { string = "", drawing = false } })
    end
    render_focus()
  end,
  apply = function(result)
    if type(result) ~= "table" then return false end
    local count = 0
    for key, row in pairs(result) do
      if type(key) ~= "number" or key % 1 ~= 0 or key < 1 or type(row) ~= "table"
        or type(row.workspace) ~= "string" or row.workspace == ""
        or type(row["app-name"]) ~= "string" or row["app-name"] == "" then return false end
      count = count + 1
    end
    if count ~= #result then return false end
    windows_current = true
    render_windows(result)
    return true
  end,
})
local focus_request = probe.new({
  command = "aerospace list-workspaces --focused",
  before = clock.now,
  max_age = 25,
  unavailable = function() focused = ""; render_focus() end,
  apply = function(result, started)
    if type(result) ~= "string" then return false end
    local sid = result:match("^%s*([^%s]+)%s*$")
    if not sid then return false end
    if started then last_event_start = math.max(last_event_start, started) end
    focused = sid
    if not windows_current and spaces[sid] then spaces[sid].item:set({ icon = { string = sid .. " —" } }) end
    render_focus()
    return true
  end,
})
local function refresh_windows() window_request.refresh() end

local refresh_generation = 0
local refresh_scheduled = false
local refresh_required = false
local switched_app
local function schedule_refresh(app)
  if type(app) == "string" and app ~= "" then switched_app = app
  else refresh_required = true end
  if refresh_scheduled then return end
  refresh_scheduled = true
  local generation = refresh_generation
  sbar.delay(0.1, function()
    if generation ~= refresh_generation then return end
    refresh_scheduled = false
    local known_app = windows_current and spaces[focused] and spaces[focused].apps[switched_app]
    local required = refresh_required or not known_app
    refresh_required, switched_app = false, nil
    if required then refresh_windows() end
  end)
end

local function refresh_immediately()
  refresh_generation = refresh_generation + 1
  refresh_scheduled = false
  refresh_required, switched_app = false, nil
  refresh_windows()
end

local observer = sbar.add("item", "aerospace.observer", {
  drawing = false,
  updates = true,
  update_freq = 5,
})
observer:subscribe("aerospace_workspace_change", function(env)
  local started = tonumber(env.EVENT_START)
  if not started or started % 1 ~= 0 or started <= last_event_start then return end
  last_event_start = started
  if not focus_request.accept(env.FOCUSED_WORKSPACE) then focus_request.refresh() end
  if not windows_current then schedule_refresh() end
end)
observer:subscribe("front_app_switched", function(env) schedule_refresh(env.INFO) end)
observer:subscribe({ "space_windows_change", "aerospace_windows_change" }, function()
  window_request.invalidate()
  schedule_refresh()
end)
observer:subscribe("routine", function()
  focus_request.refresh()
  schedule_refresh()
end)
observer:subscribe({ "system_woke", "forced" }, function()
  focus_request.refresh(true)
  window_request.invalidate()
  refresh_immediately()
end)
focus_request.refresh()
refresh_windows()
