local app_icons = require("helpers.app_icons")

local front_app = sbar.add("item", "front_app", {
  position = "left",
  icon = {
    font = settings.font.app_large,
    color = colors.lavender,
  },
  label = {
    font = settings.font.text_bold,
    color = colors.lavender,
  },
  background = { drawing = false },
})

front_app:subscribe("front_app_switched", function(env)
  front_app:set({
    icon = { string = app_icons[env.INFO] or ":default:" },
    label = { string = env.INFO },
  })
end)
