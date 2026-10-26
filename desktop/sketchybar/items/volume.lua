local probe = require("helpers.probe")
local details = { "サウンド", "計測中" }
local sampled
local diagnostic = require("helpers.diagnostics")

local volume = sbar.add("item", "widgets.volume", {
  position = "right",
  icon = {
    string = icons.volume._100,
    color = colors.pure_white,
    font = {
      style = settings.font.style_map["Regular"],
      size = 14.0,
    },
    padding_right = 4,
  },
  label = {
    string = "—",
    width = 39,
    font = { family = settings.font.numbers },
  },
  background = { drawing = false },
  update_freq = 30,
})

local request = probe.new({
  command = '"$HOME/.local/bin/desktop-audio"',
  max_age = 65,
  unavailable = function(reason)
    sampled = nil
    details = { "サウンド", "現在の値を取得できません" }
    volume:set({ icon = { string = "?", color = colors.grey }, label = "—" })
  end,
  apply = function(result)
    if type(result) ~= "table" or not probe.number(result.device, 1) then return false end
    if result.name ~= nil and (type(result.name) ~= "string" or result.name == "") then return false end
    for _, key in ipairs({ "sample_rate", "buffer_frames", "monotonic" }) do
      if result[key] ~= nil and not probe.number(result[key], 0) then return false end
    end
    if result.writable ~= nil and type(result.writable) ~= "boolean" then return false end
    if result.buffer_frames ~= nil and result.buffer_frames % 1 ~= 0 then return false end
    sampled = result.monotonic
    local field = diagnostic.field
    local function format_details(status)
      local rows = { "サウンド", result.name or ("Output ID " .. result.device), "Sampled state: " .. status }
      if result.sample_rate and result.sample_rate > 0 then rows[#rows + 1] = field("Nominal rate", string.format("%.1f kHz", result.sample_rate / 1000)) end
      if result.buffer_frames and result.buffer_frames > 0 then
        rows[#rows + 1] = field("I/O buffer", result.buffer_frames .. " frames")
        if result.sample_rate and result.sample_rate > 0 then rows[#rows + 1] = field("Buffer duration", string.format("%.2f ms", 1000 * result.buffer_frames / result.sample_rate)) end
      end
      if result.writable ~= nil then rows[#rows + 1] = result.writable and "Volume control: supported" or "Volume control: read-only" end
      if result.buffer_frames and result.sample_rate then rows[#rows + 1] = "Buffer duration ≠ end-to-end latency" end
      return rows
    end
    if result.volume == nil then
      details = format_details("音量は取得できません")
      volume:set({ icon = { string = icons.volume._100, color = colors.grey }, label = "—" })
      return true
    end
    if not probe.number(result.volume, 0, 100) or type(result.muted) ~= "boolean" then return false end
    local vol = math.floor(result.volume + 0.5)
    details = format_details(result.muted and "消音中" or (vol .. "%"))
    local icon = icons.volume._0
    if not result.muted then
      if vol > 60 then icon = icons.volume._100
      elseif vol > 30 then icon = icons.volume._66
      elseif vol > 0 then icon = icons.volume._33 end
    end
    volume:set({ icon = { string = icon, color = colors.pure_white }, label = result.muted and "消音" or vol .. "%" })
    return true
  end,
})
volume:subscribe({ "forced", "routine" }, function() request.refresh() end)
volume:subscribe("system_woke", function() request.refresh(true) end)

volume:subscribe("volume_change", function() request.refresh(true) end)
require("helpers.menu").bind({ volume }, "volume", function() return details, sampled end)
