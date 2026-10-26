local details = { "CPU", "計測中" }
local sampled
local diagnostic = require("helpers.diagnostics")
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

local function update(percent, seconds, data)
  local load = math.floor(math.max(0, math.min(percent, 100)) + 0.5)
  data = data or {}
  sampled = data.monotonic
  local field = diagnostic.field
  details = { "CPU", field("Busy (all CPUs)", load .. "%") }
  if data.user then
    details[#details + 1] = field("User / System", string.format("%.1f%% / %.1f%%", data.user, data.system))
    details[#details + 1] = field("Idle / Nice", string.format("%.1f%% / %.1f%%", data.idle, data.nice))
  end
  if data.load_average then details[#details + 1] = field("Load 1 / 5 / 15m", string.format("%.2f / %.2f / %.2f", table.unpack(data.load_average))) end
  if data.physical_cpus and data.physical_cpus > 0 and data.logical_cpus and data.logical_cpus > 0 then
    details[#details + 1] = field("Physical / Logical", data.physical_cpus .. " / " .. data.logical_cpus)
  end
  details[#details + 1] = field("Interval", string.format("%.1f s", seconds))
  details[#details + 1] = "100% = 全論理CPUの合計容量"
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
  sampled = nil
  details = { "CPU", reason or "現在の値を取得できません" }
  cpu:set({ label = { string = "—", color = colors.grey }, icon = { color = colors.grey } })
  cpu_graph:set({ drawing = false })
end

require("helpers.menu").bind({ cpu, cpu_graph }, "cpu", function() return details, sampled end)

return { update = update, unavailable = unavailable }
