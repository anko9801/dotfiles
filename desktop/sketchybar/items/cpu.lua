sbar.add("item", "wifi.cpu.padding", {
  position = "right",
  icon = { drawing = false },
  label = { drawing = false },
  background = { drawing = false },
  padding_left = 0,
  padding_right = 0,
  width = 4,
})

local cpu = sbar.add("item", "cpu", {
  position = "right",
  icon = { color = colors.sky },
  label = { color = colors.sky },
  background = { drawing = false },
  update_freq = 3,
})

cpu:subscribe("mouse.clicked", function()
  sbar.exec("open -a 'Activity Monitor'")
end)

local cpu_graph = sbar.add("graph", "cpu_graph", 60, {
  position = "right",
  graph = {
    color = colors.sky,
    fill_color = colors.with_alpha(colors.sky, 0x40),
    line_width = 1.0,
  },
  background = {
    drawing = true,
    color = 0x00000000,
    height = 24,
    border_width = 0,
  },
  label = { drawing = false },
  icon = { drawing = false },
  width = 60,
})

local cpu_bracket = sbar.add("bracket", "cpu_bracket", { "cpu", "cpu_graph" }, {
  background = {
    color = colors.surface,
    corner_radius = 8,
    height = 28,
    border_color = colors.sky,
    border_width = 2,
  },
})

sbar.add("item", "cpu.padding", {
  position = "right",
  icon = { drawing = false },
  label = { drawing = false },
  background = { drawing = false },
  padding_left = 0,
  padding_right = 0,
  width = 16,
})

cpu:subscribe("routine", function()
  sbar.exec([[ps -A -o %cpu | awk '{s+=$1} END {printf "%.0f", s}']], function(result)
    local cpu_val = tonumber(result) or 0
    local cpu_percent = math.min(cpu_val / 150, 1.0)

    local color
    if cpu_val > 80 then
      color = colors.red
    elseif cpu_val > 60 then
      color = colors.peach
    elseif cpu_val > 30 then
      color = colors.yellow
    else
      color = colors.sky
    end

    cpu:set({
      icon = { string = icons.cpu, color = color },
      label = { string = cpu_val .. "%", color = color },
    })
    cpu_graph:set({ graph = { color = color } })
    cpu_bracket:set({ background = { border_color = color } })
    cpu_graph:push({ cpu_percent })
  end)
end)
