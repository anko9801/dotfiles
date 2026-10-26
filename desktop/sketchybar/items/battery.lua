local power = require("helpers.power")
local probe = require("helpers.probe")
local battery = sbar.add("item", "widgets.battery", {
  position = "right",
  icon = { font = { style = settings.font.style_map.Regular, size = 19.0 } },
  label = { string = "—", width = 39, font = { family = settings.font.numbers } },
  background = { drawing = false },
  update_freq = 30,
})
local request = probe.new({
  command = "LC_ALL=C /usr/bin/pmset -g batt",
  max_age = 65,
  unavailable = function(reason)
    battery:set({ drawing = true, icon = { string = "?", color = colors.grey }, label = "—" })
  end,
  apply = function(info)
    if type(info) ~= "string" then return false end
    if info:find("No batteries", 1, true) then battery:set({ drawing = false }); return true end
    local source = info:match("Now drawing from '([^']+)'")
    local charge, state = info:match("(%d+)%%;%s*([^;]+)")
    charge = tonumber(charge)
    if not probe.number(charge, 0, 100) or (source ~= "AC Power" and source ~= "Battery Power") then return false end
    state = state and state:match("^%s*(.-)%s*$")
    local states = { charging = "充電中", charged = "満充電", discharging = "バッテリー駆動",
      ["not charging"] = "充電停止", ["AC attached"] = "電源接続", ["finishing charge"] = "充電中" }
    if not states[state] then return false end
    power.update(source == "AC Power")
    local icon, color = icons.battery.full, colors.green
    if state == "charging" or state == "finishing charge" then icon = icons.battery.charging
    elseif source == "AC Power" then icon = icons.battery.plug
    elseif charge <= 20 then icon, color = icons.battery.empty, colors.red
    elseif charge <= 40 then icon, color = icons.battery.low, colors.peach
    elseif charge <= 60 then icon = icons.battery.medium
    elseif charge <= 80 then icon = icons.battery.high end
    battery:set({ drawing = true, icon = { string = icon, color = color }, label = charge .. "%" })
    return true
  end,
})

battery:subscribe({ "forced", "routine" }, function() request.refresh() end)
battery:subscribe({ "power_source_change", "system_woke" }, function() request.refresh(true) end)
battery:subscribe("mouse.clicked", function()
  sbar.exec("open /System/Library/PreferencePanes/Battery.prefPane")
end)
