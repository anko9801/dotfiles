-- Get core count once for normalization
local ncpu = 1
local h = io.popen("sysctl -n hw.ncpu 2>/dev/null")
if h then
  ncpu = tonumber(h:read("*a")) or 1
  h:close()
end

local cpu = sbar.add("item", "widgets.cpu.label", {
  position = "right",
  icon = { string = icons.cpu, color = colors.sky },
  label = {
    string = "??%",
    color = colors.sky,
    font = { family = settings.font.numbers },
  },
  background = { drawing = false },
  update_freq = 3,
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

cpu:subscribe("routine", function()
  sbar.exec([[ps -A -o %cpu | awk '{s+=$1} END {printf "%.0f", s}']], function(result)
    local raw = tonumber(result) or 0
    local load = math.floor(raw / ncpu)
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
    cpu_graph:set({ graph = { color = color } })
  end)
end)

cpu:subscribe("mouse.clicked", function()
  sbar.exec("open -a 'Activity Monitor'")
end)
