local shell = require("helpers.shell")
local probe = require("helpers.probe")
local baseline
local wifi = sbar.add("item", "widgets.wifi", {
  position = "right",
  icon = { string = icons.network, color = colors.grey },
  label = { string = "—", width = 145, font = { family = settings.font.numbers, size = 11 } },
  background = { drawing = false },
  update_freq = 10,
  popup = { align = "center", height = 30 },
})
local fields = {}
local function field(key, title)
  local item = sbar.add("item", "widgets.wifi." .. key, {
    position = "popup." .. wifi.name,
    icon = { string = title, width = 115, align = "left" },
    label = { string = "—", width = 260, align = "right" },
  })
  fields[key] = { item = item }
  item:subscribe("mouse.clicked", function()
    local value = fields[key].value
    if value then sbar.exec("printf '%s' " .. shell.quote(value) .. " | pbcopy") end
  end)
end
field("interface", "インターフェース")
field("hostname", "ホスト名")
field("address", "IPアドレス")
field("gateway", "ルーター")
field("sample", "取得状況")
local function set_field(key, value)
  fields[key].value = value
  fields[key].item:set({ label = value or "—" })
end
local function reset(reason)
  baseline = nil
  wifi:set({ label = "—", icon = { string = icons.network, color = colors.grey } })
  for key in pairs(fields) do set_field(key, nil) end
  set_field("sample", reason)
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
    for _, key in ipairs({ "interface", "address", "gateway", "hostname" }) do set_field(key, result[key]) end
    local description = label == "—" and "速度カウンター取得不可" or label == "計測中" and "速度の計測区間を準備中"
      or string.format("直近%.1f秒の平均", elapsed)
    set_field("sample", description .. " · " .. os.date("%H:%M:%S") .. "取得")
    wifi:set({ label = label, icon = { string = icons.network, color = result.address and colors.pure_white or colors.grey } })
    if label == "計測中" then sbar.delay(1, function() request.refresh() end) end
    baseline = result.rx_bytes and result.tx_bytes and result or nil
    return true
  end,
})
wifi:subscribe({ "forced", "routine" }, function() request.refresh() end)
wifi:subscribe({ "wifi_change", "network_change", "system_woke" }, function() request.refresh(true) end)
wifi:subscribe("mouse.clicked", function()
  wifi:set({ popup = { drawing = wifi:query().popup.drawing == "off" } })
  request.refresh()
end)
wifi:subscribe("mouse.exited.global", function() wifi:set({ popup = { drawing = false } }) end)
