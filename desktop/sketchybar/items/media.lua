local media = sbar.add("item", "media", {
  position = "right",
  icon = { string = icons.media.playing, color = colors.pink },
  label = { color = colors.pink, max_chars = 25 },
  background = { border_color = colors.pink },
  scroll_texts = true,
  drawing = false,
})

media:subscribe("mouse.clicked", function()
  media:set({ popup = { drawing = "toggle" } })
end)

media:subscribe("media_change", function(env)
  local state = (env.INFO or ""):match('"state":"([^"]*)"')
  local title = (env.INFO or ""):match('"title":"([^"]*)"') or ""
  local artist = (env.INFO or ""):match('"artist":"([^"]*)"') or ""

  if state == "playing" then
    media:set({
      drawing = true,
      icon = { string = icons.media.playing },
      label = { string = artist .. " - " .. title },
    })
  elseif state == "paused" then
    media:set({
      drawing = true,
      icon = { string = icons.media.paused },
      label = { string = artist .. " - " .. title },
    })
  else
    media:set({ drawing = false })
  end
end)

local prev = sbar.add("item", "media.prev", {
  position = "popup.media",
  icon = { string = icons.media.prev, color = colors.pink, padding_left = 8, padding_right = 8 },
  label = { drawing = false },
  background = { drawing = false },
})
prev:subscribe("mouse.clicked", function()
  sbar.exec("nowplaying-cli previous 2>/dev/null")
end)

local play_pause = sbar.add("item", "media.playpause", {
  position = "popup.media",
  icon = { string = icons.media.play_pause, color = colors.pink, padding_left = 8, padding_right = 8 },
  label = { drawing = false },
  background = { drawing = false },
})
play_pause:subscribe("mouse.clicked", function()
  sbar.exec("nowplaying-cli togglePlayPause 2>/dev/null")
end)

local next_btn = sbar.add("item", "media.next", {
  position = "popup.media",
  icon = { string = icons.media.next, color = colors.pink, padding_left = 8, padding_right = 8 },
  label = { drawing = false },
  background = { drawing = false },
})
next_btn:subscribe("mouse.clicked", function()
  sbar.exec("nowplaying-cli next 2>/dev/null")
end)
