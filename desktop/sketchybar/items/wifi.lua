local probe = require("helpers.probe")
local baseline
local details = { "ネットワーク", "計測中" }
local wifi = sbar.add("item", "widgets.wifi", {
  position = "right",
  icon = { string = icons.network, color = colors.grey },
  label = { string = "—", width = 128, font = { family = settings.font.numbers, size = 10 } },
  background = { drawing = false },
  update_freq = 10,
})
local function reset(reason)
  details = { "ネットワーク", reason or "現在の値を取得できません" }
  baseline = nil
  wifi:set({ label = "—", icon = { string = icons.network, color = colors.grey } })
end
local function speed(rate)
  if rate > 0 and rate < 0.1 then return "<0.1B/s" end
  local divisor, unit = 1, "B/s"
  if rate >= 1e6 then divisor, unit = 1e6, "MB/s"
  elseif rate >= 1e3 then divisor, unit = 1e3, "kB/s" end
  local value = rate / divisor
  return string.format(value < 100 and "%.1f%s" or "%.0f%s", value, unit)
end

sbar.add("event", "network_change")
local request
request = probe.new({
  command = '"$HOME/.local/bin/desktop-network"',
  max_age = 65,
  unavailable = reset,
  apply = function(result)
    if type(result) ~= "table" then return false end
    if result.status == "no-route" then
      reset("既定のネットワーク経路がありません")
      wifi:set({ label = "経路なし" })
      return true
    end
    if result.status ~= "interface" or type(result.interface) ~= "string" or result.interface == ""
      or not probe.number(result.monotonic, 0) then return false end
    for _, key in ipairs({ "address", "gateway", "hostname" }) do
      if result[key] ~= nil and (type(result[key]) ~= "string" or result[key] == "") then return false end
    end
    if result.rx_bytes ~= nil and not probe.number(result.rx_bytes, 0, 2^53) then return false end
    if result.tx_bytes ~= nil and not probe.number(result.tx_bytes, 0, 2^53) then return false end
    if (result.rx_bytes and result.rx_bytes % 1 ~= 0) or (result.tx_bytes and result.tx_bytes % 1 ~= 0) then return false end
    local elapsed = baseline and result.monotonic - baseline.monotonic or 0
    local compatible = baseline and baseline.interface == result.interface and baseline.address == result.address
      and baseline.gateway == result.gateway and baseline.rx_bytes and baseline.tx_bytes
    local label = "計測中"
    if result.rx_bytes == nil or result.tx_bytes == nil then
      label = "—"
      baseline = nil
    elseif compatible and elapsed > 0 and elapsed <= 65
      and result.rx_bytes >= baseline.rx_bytes and result.tx_bytes >= baseline.tx_bytes then
      label = "↑" .. speed((result.tx_bytes - baseline.tx_bytes) / elapsed)
        .. " ↓" .. speed((result.rx_bytes - baseline.rx_bytes) / elapsed)
    end
    wifi:set({ label = label, icon = { string = icons.network, color = result.address and colors.pure_white or colors.grey } })
    details = { "ネットワーク", "通信速度  " .. label, "接続先  " .. result.interface,
      "IPアドレス  " .. (result.address or "不明"), "ゲートウェイ  " .. (result.gateway or "不明") }
    if label == "計測中" then sbar.delay(1, function() request.refresh() end) end
    baseline = result.rx_bytes and result.tx_bytes and result or nil
    return true
  end,
})
wifi:subscribe({ "forced", "routine" }, function() request.refresh() end)
wifi:subscribe({ "wifi_change", "network_change", "system_woke" }, function() request.refresh(true) end)
require("helpers.menu").bind({ wifi }, "network", function() return details end)
