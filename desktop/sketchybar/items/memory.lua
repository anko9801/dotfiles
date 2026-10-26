local details = { "メモリ", "計測中" }
local sampled
local diagnostic = require("helpers.diagnostics")
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

local function update(percent, pressure, swap_gib, data)
  percent = math.floor(math.max(0, math.min(percent, 100)) + 0.5)
  local pressures = { [0] = "不明", [1] = "正常", [2] = "注意", [4] = "高い" }
  data = data or {}
  sampled = data.monotonic
  local field, gib = diagnostic.field, diagnostic.gib
  details = { "メモリ", field("Used (estimate)", data.memory_bytes and (gib(data.memory_bytes) .. " / " .. gib(data.total_bytes)) or ("~" .. percent .. "%")),
    "Memory pressure: " .. pressures[pressure],
    field("Swap used / total", swap_gib >= 0 and (string.format("%.2f GiB", swap_gib) .. (data.swap_total_gib and string.format(" / %.2f GiB", data.swap_total_gib) or "")) or "不明") }
  if data.anonymous_bytes then
    details[#details + 1] = field("Anon / Wired", gib(data.anonymous_bytes) .. " / " .. gib(data.wired_bytes))
    details[#details + 1] = field("Purgeable", gib(data.purgeable_bytes))
    details[#details + 1] = field("Compressor RAM", gib(data.compressed_bytes))
    details[#details + 1] = field("File-backed", gib(data.file_backed_bytes))
    local swap_rate = data.swap_in_pages_per_second and data.swap_out_pages_per_second
      and string.format("%.1f / %.1f pages/s", data.swap_in_pages_per_second, data.swap_out_pages_per_second) or "—"
    details[#details + 1] = field("Swap in / out", swap_rate)
    if data.page_size then details[#details + 1] = field("Page size", string.format("%.0f KiB", data.page_size / 1024)) end
  end
  if data.interval then details[#details + 1] = field("Interval", string.format("%.1f s", data.interval)) end
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
  sampled = nil
  details = { "メモリ", reason or "現在の値を取得できません" }
  memory:set({ label = { string = "—", color = colors.grey }, icon = { color = colors.grey } })
  mem_graph:set({ drawing = false })
end

require("helpers.menu").bind({ memory, mem_graph }, "memory", function() return details, sampled end)

return { update = update, unavailable = unavailable }
