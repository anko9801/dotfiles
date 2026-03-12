local clock = sbar.add("item", "clock", {
  position = "right",
  icon = { drawing = false },
  label = { font = settings.font.clock, color = colors.blue },
  background = { drawing = false },
  update_freq = 10,
})

clock:subscribe({ "routine", "system_woke" }, function()
  clock:set({ label = os.date("%H:%M") })
end)

local date = sbar.add("item", "date", {
  position = "right",
  icon = { drawing = false },
  label = { font = settings.font.date, color = colors.blue },
  background = { drawing = false },
  update_freq = 60,
})

date:subscribe({ "routine", "system_woke" }, function()
  date:set({ label = os.date("%a %m/%d") })
end)

sbar.add("bracket", "cal", { "clock", "date" }, {
  background = {
    color = colors.surface,
    corner_radius = 8,
    height = 28,
    border_color = colors.blue,
    border_width = 2,
  },
})
