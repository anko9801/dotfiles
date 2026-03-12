local battery = sbar.add("item", "widgets.battery", {
  position = "right",
  icon = {
    font = {
      style = settings.font.style_map["Regular"],
      size = 19.0,
    },
  },
  label = { font = { family = settings.font.numbers } },
  background = { drawing = false },
  update_freq = 180,
  popup = { align = "center" },
})

local remaining_time = sbar.add("item", {
  position = "popup." .. battery.name,
  icon = {
    string = "Time remaining:",
    width = 100,
    align = "left",
  },
  label = {
    string = "??:??h",
    width = 100,
    align = "right",
  },
})

battery:subscribe({ "routine", "power_source_change", "system_woke" }, function()
  sbar.exec("pmset -g batt", function(batt_info)
    local icon = "!"
    local label = "?"

    local found, _, charge = batt_info:find("(%d+)%%")
    if found then
      charge = tonumber(charge)
      label = charge .. "%"
    end

    local color = colors.green
    local charging = batt_info:find("AC Power")

    if charging then
      icon = icons.battery.charging
    else
      if found and charge > 80 then
        icon = icons.battery.full
      elseif found and charge > 60 then
        icon = icons.battery.high
      elseif found and charge > 40 then
        icon = icons.battery.medium
      elseif found and charge > 20 then
        icon = icons.battery.low
        color = colors.peach
      else
        icon = icons.battery.empty
        color = colors.red
      end
    end

    local lead = ""
    if found and charge < 10 then
      lead = "0"
    end

    battery:set({
      icon = { string = icon, color = color },
      label = { string = lead .. label },
    })
  end)
end)

battery:subscribe("mouse.clicked", function()
  local should_draw = battery:query().popup.drawing == "off"
  if should_draw then
    battery:set({
      popup = { drawing = true },
      background = { drawing = true, color = colors.bar.bg, border_width = 0 },
    })
    sbar.exec("pmset -g batt", function(batt_info)
      local found, _, remaining = batt_info:find(" (%d+:%d+) remaining")
      local label = found and remaining .. "h" or "No estimate"
      remaining_time:set({ label = label })
    end)
  else
    battery:set({
      popup = { drawing = false },
      background = { drawing = false },
    })
  end
end)

battery:subscribe("mouse.exited.global", function()
  battery:set({
    popup = { drawing = false },
    background = { drawing = false },
  })
end)
