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
  popup = { align = "center" },
})

local details = sbar.add("item", "widgets.memory.details", {
  position = "popup." .. memory.name,
  icon = { drawing = false },
  label = { string = "Waiting for sample" },
})

local mem_graph = sbar.add("graph", "widgets.memory.graph", 42, {
  position = "right",
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
  local status = ({ [1] = "正常", [2] = "警告", [4] = "危険" })[pressure] or "不明"

  memory:set({
    icon = { color = color },
    label = { string = "~" .. percent .. "%", color = color },
  })
  mem_graph:set({ drawing = true, graph = { color = color } })
  local swap = swap_gib >= 0 and string.format("%.1f GiB", swap_gib) or "不明"
  details:set({ label = string.format("使用率は推定値 · メモリ圧迫:%s · Swap:%s · %s取得", status, swap, os.date("%H:%M:%S")) })
end

local function unavailable(reason)
  memory:set({ label = { string = "—", color = colors.grey }, icon = { color = colors.grey } })
  mem_graph:set({ drawing = false })
  details:set({ label = reason })
end

memory:subscribe("mouse.entered", function()
  memory:set({ popup = { drawing = true } })
end)
memory:subscribe("mouse.exited.global", function()
  memory:set({ popup = { drawing = false } })
end)

memory:subscribe("mouse.clicked", function()
  sbar.exec("open -a 'Activity Monitor'")
end)

return { update = update, unavailable = unavailable }
