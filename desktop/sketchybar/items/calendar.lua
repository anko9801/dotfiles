local cal = sbar.add("item", {
  icon = {
    color = colors.white,
    padding_left = 8,
    font = {
      family = "SF Pro",
      style = "Semibold",
      size = 13.0,
    },
  },
  label = {
    color = colors.white,
    padding_right = 8,
    width = 49,
    align = "right",
    font = { family = "SF Pro", style = "Semibold", size = 13.0 },
  },
  position = "right",
  update_freq = 30,
  background = { drawing = false },
  click_script = "open -a 'Calendar'",
})

cal:subscribe({ "forced", "routine", "system_woke" }, function()
  local weekdays = { "日", "月", "火", "水", "木", "金", "土" }
  local wday = weekdays[tonumber(os.date("%w")) + 1]
  local date_str = os.date("%m月%d日"):gsub("0(%d)", "%1")
  cal:set({
    icon = date_str .. " (" .. wday .. ")",
    label = os.date("%H:%M"),
  })
end)
