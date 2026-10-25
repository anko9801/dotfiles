local cpu = sbar.add("item", "widgets.cpu.label", {
  position = "right",
  icon = { string = icons.cpu, color = colors.sky },
  label = {
    string = "—",
    width = 34,
    color = colors.sky,
    font = { family = settings.font.numbers },
  },
  background = { drawing = false },
  popup = { align = "center" },
})

local details = sbar.add("item", "widgets.cpu.details", {
  position = "popup." .. cpu.name,
  icon = { drawing = false },
  label = { string = "計測待ち" },
})

local cpu_graph = sbar.add("graph", "widgets.cpu.graph", 42, {
  position = "right",
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
  if load > 30 then
    if load < 60 then
      color = colors.yellow
    elseif load < 80 then
      color = colors.peach
    else
      color = colors.red
    end
  end

  cpu:set({
    icon = { color = color },
    label = { string = load .. "%", color = color },
  })
  cpu_graph:set({ drawing = true, graph = { color = color } })
  details:set({ label = string.format("全CPU合計100%% · 直近%.1f秒の平均 · %s取得", seconds, os.date("%H:%M:%S")) })
end

local function unavailable(reason)
  cpu:set({ label = { string = "—", color = colors.grey }, icon = { color = colors.grey } })
  cpu_graph:set({ drawing = false })
  details:set({ label = reason })
end

cpu:subscribe("mouse.entered", function() cpu:set({ popup = { drawing = true } }) end)
cpu:subscribe("mouse.exited.global", function() cpu:set({ popup = { drawing = false } }) end)

cpu:subscribe("mouse.clicked", function()
  sbar.exec("open -a 'Activity Monitor'")
end)

return { update = update, unavailable = unavailable }
