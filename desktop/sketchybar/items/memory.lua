local memory = sbar.add("item", "widgets.memory.label", {
  position = "right",
  padding_right = 12,
  icon = { string = icons.memory, color = colors.teal },
  label = {
    string = "—",
    width = 44,
    color = colors.teal,
    font = { family = settings.font.numbers },
  },
  background = { drawing = false },
})

local mem_graph = sbar.add("graph", "widgets.memory.graph", 42, {
  position = "right",
  padding_left = 0, padding_right = 0,
  graph = { color = colors.teal },
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

local function update(percent, pressure, swap_gib)
  percent = math.floor(math.max(0, math.min(percent, 100)) + 0.5)
  local graph_val = math.min(percent / 100.0, 1.0)
  mem_graph:push({ graph_val })

  local color = colors.teal
  if pressure == 2 then color = colors.yellow end
  if pressure == 4 then color = colors.red end
  if pressure == 0 then color = colors.grey end

  memory:set({
    icon = { color = color },
    label = { string = "~" .. percent .. "%", color = color },
  })
  mem_graph:set({ drawing = true, graph = { color = color } })
end

local function unavailable(reason)
  memory:set({ label = { string = "—", color = colors.grey }, icon = { color = colors.grey } })
  mem_graph:set({ drawing = false })
end

local function open_monitor() sbar.exec("open -a 'Activity Monitor'") end
memory:subscribe("mouse.clicked", open_monitor)
mem_graph:subscribe("mouse.clicked", open_monitor)

return { update = update, unavailable = unavailable }
