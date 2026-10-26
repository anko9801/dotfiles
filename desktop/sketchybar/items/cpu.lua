local cpu = sbar.add("item", "widgets.cpu.label", {
  position = "right",
  icon = { string = icons.cpu, color = colors.sky },
  label = {
    string = "—",
    width = 34,
    drawing = false,
    color = colors.sky,
    font = { family = settings.font.numbers },
  },
  background = { drawing = false },
})

local cpu_graph = sbar.add("graph", "widgets.cpu.graph", 42, {
  position = "right",
  padding_left = 0, padding_right = 0,
  graph = { color = colors.sky },
  background = {
    height = 22,
    color = { alpha = 0 },
    border_color = { alpha = 0 },
    drawing = true,
  },
  icon = { drawing = false },
  label = { drawing = false },
  width = 42,
})

local function update(percent, seconds)
  local load = math.floor(math.max(0, math.min(percent, 100)) + 0.5)
  local graph_val = math.min(load / 100.0, 1.0)
  cpu_graph:push({ graph_val })

  local color = colors.sky

  cpu:set({
    icon = { color = color },
    label = { string = load .. "%", color = color },
  })
  cpu_graph:set({ drawing = true, graph = { color = color } })
end

local function unavailable(reason)
  cpu:set({ label = { string = "—", color = colors.grey }, icon = { color = colors.grey } })
  cpu_graph:set({ drawing = false })
end

local function open_monitor() sbar.exec("open -a 'Activity Monitor'") end
cpu:subscribe("mouse.clicked", open_monitor)
cpu_graph:subscribe("mouse.clicked", open_monitor)

return { update = update, unavailable = unavailable }
