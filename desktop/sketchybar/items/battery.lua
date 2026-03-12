local battery = sbar.add("item", "battery", {
  position = "right",
  icon = { color = colors.peach },
  label = { color = colors.peach },
  background = { border_color = colors.peach },
  update_freq = 60,
})

battery:subscribe("mouse.clicked", function()
  battery:set({ popup = { drawing = "toggle" } })
end)

local battery_remaining = sbar.add("item", "battery.remaining", {
  position = "popup.battery",
  icon = { string = icons.remaining, color = colors.peach },
  label = { color = colors.peach },
  background = { drawing = false },
})

battery:subscribe({ "routine", "power_source_change", "system_woke" }, function()
  sbar.exec("pmset -g batt", function(result)
    local percentage = result:match("(%d+)%%")
    local charging = result:find("AC Power") ~= nil
    local charge = tonumber(percentage) or 0
    local remaining = result:match("(%d+:%d+)")

    local icon
    if charging then
      icon = icons.battery.charging
    elseif charge > 80 then
      icon = icons.battery.full
    elseif charge > 60 then
      icon = icons.battery.high
    elseif charge > 40 then
      icon = icons.battery.medium
    elseif charge > 20 then
      icon = icons.battery.low
    else
      icon = icons.battery.empty
    end

    battery:set({
      icon = { string = icon },
      label = { string = percentage and (percentage .. "%") or "?" },
    })

    if remaining and remaining ~= "0:00" then
      battery_remaining:set({ label = remaining .. " remaining" })
    elseif charging then
      battery_remaining:set({ label = "Charging" })
    else
      battery_remaining:set({ label = "Calculating..." })
    end
  end)
end)
