local cal = sbar.add("item", "widgets.calendar", {
  icon = {
    color = colors.pure_white,
    padding_left = 0,
    font = {
      family = ".AppleSystemUIFont",
      style = "Semibold",
      size = 13.0,
    },
  },
  label = {
    color = colors.pure_white,
    padding_right = 8,
    font = { family = ".AppleSystemUIFont", style = "Semibold", size = 13.0 },
  },
  position = "right",
  update_freq = 1,
  background = { drawing = false },
  click_script = "open -a 'Calendar'",
})

local last_text
local function render()
  local current = os.date("*t", os.time())
  local weekdays = { "日", "月", "火", "水", "木", "金", "土" }
  local date = string.format("%d月%d日 (%s)", current.month, current.day, weekdays[current.wday])
  local time = string.format("%d:%02d", current.hour, current.min)
  local text = date .. time
  if text == last_text then return end
  last_text = text
  cal:set({ icon = date, label = time })
end

cal:subscribe({ "forced", "routine", "system_woke" }, render)
