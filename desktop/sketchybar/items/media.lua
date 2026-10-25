local probe = require("helpers.probe")

local media_cover = sbar.add("item", {
  position = "right",
  background = {
    color = colors.transparent,
  },
  label = { drawing = false },
  icon = { string = "󰎈", drawing = true },
  drawing = false,
  updates = true,
  popup = {
    align = "center",
    horizontal = true,
  },
})

local media_artist = sbar.add("item", {
  position = "right",
  drawing = false,
  padding_left = 3,
  padding_right = 0,
  width = 0,
  icon = { drawing = false },
  label = {
    width = 0,
    font = { size = 9 },
    color = colors.with_alpha(colors.white, 0.6),
    max_chars = 18,
    y_offset = 6,
  },
})

local media_title = sbar.add("item", {
  position = "right",
  drawing = false,
  padding_left = 3,
  padding_right = 0,
  icon = { drawing = false },
  label = {
    font = { size = 11 },
    width = 0,
    max_chars = 16,
    y_offset = -5,
  },
})

sbar.add("item", {
  position = "popup." .. media_cover.name,
  icon = { string = icons.media.back },
  label = { drawing = false },
  click_script = "nowplaying-cli previous 2>/dev/null",
})
sbar.add("item", {
  position = "popup." .. media_cover.name,
  icon = { string = icons.media.play_pause },
  label = { drawing = false },
  click_script = "nowplaying-cli togglePlayPause 2>/dev/null",
})
sbar.add("item", {
  position = "popup." .. media_cover.name,
  icon = { string = icons.media.forward },
  label = { drawing = false },
  click_script = "nowplaying-cli next 2>/dev/null",
})

local generation = 0
local hovered = false
local expanded = false
local last_track
local function animate_detail(detail)
  if expanded == detail then return end
  expanded = detail
  sbar.animate("tanh", 12, function()
    media_artist:set({ label = { width = detail and "dynamic" or 0 } })
    media_title:set({ label = { width = detail and "dynamic" or 0 } })
  end)
end

local function hide()
  generation = generation + 1
  hovered, expanded, last_track = false, false, nil
  media_artist:set({ drawing = false, label = { string = "", width = 0 } })
  media_title:set({ drawing = false, label = { string = "", width = 0 } })
  media_cover:set({ drawing = false, popup = { drawing = false } })
end

local observer = sbar.add("item", "media.observer", { drawing = false, updates = true, update_freq = 60 })
local request = probe.new({
  command = "nowplaying-cli get --json title artist playbackRate",
  max_age = 125,
  unavailable = hide,
  apply = function(info)
    if type(info) ~= "table" then return false end
    if info.title == nil and info.playbackRate == nil then hide(); return true end
    if not probe.number(info.playbackRate, 0, 16) then return false end
    if info.playbackRate == 0 then hide(); return true end
    if type(info.title) ~= "string" or info.title == ""
      or (info.artist ~= nil and type(info.artist) ~= "string") then return false end
    local artist, title = info.artist or "", info.title
    local track = artist .. "\0" .. title
    if track == last_track then return true end
    last_track = track
    generation = generation + 1
    local current = generation
    media_artist:set({ drawing = true, label = artist })
    media_title:set({ drawing = true, label = title })
    media_cover:set({ drawing = true })
    animate_detail(true)
    sbar.delay(5, function()
      if generation == current and not hovered then animate_detail(false) end
    end)
    return true
  end,
})
observer:subscribe({ "forced", "routine" }, function() request.refresh() end)
observer:subscribe({ "media_change", "system_woke" }, function() request.refresh(true) end)

media_cover:subscribe("mouse.entered", function()
  hovered = true
  animate_detail(true)
end)
media_cover:subscribe("mouse.exited", function()
  hovered = false
  animate_detail(false)
end)

media_cover:subscribe("mouse.clicked", function()
  media_cover:set({ popup = { drawing = "toggle" } })
end)

media_title:subscribe("mouse.exited.global", function()
  media_cover:set({ popup = { drawing = false } })
end)
