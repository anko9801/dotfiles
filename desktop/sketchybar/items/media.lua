local probe = require("helpers.probe")
local media = sbar.add("item", "widgets.media", {
  position = "right", width = 28, drawing = false, updates = true,
  icon = { string = "󰎈" }, label = { drawing = false },
  background = { drawing = false },
})
local function hide() media:set({ drawing = false }) end
local observer = sbar.add("item", "media.observer", { drawing = false, updates = true, update_freq = 60 })
local request = probe.new({
  command = "nowplaying-cli get --json title artist playbackRate", max_age = 125,
  unavailable = hide,
  apply = function(info)
    if type(info) ~= "table" then return false end
    if info.title == nil and info.playbackRate == nil then hide(); return true end
    if not probe.number(info.playbackRate, 0, 16) or type(info.title) ~= "string" or info.title == ""
      or (info.artist ~= nil and type(info.artist) ~= "string") then return false end
    media:set({ drawing = true, icon = { color = info.playbackRate == 0 and colors.grey or colors.white } })
    return true
  end,
})
observer:subscribe({ "forced", "routine" }, function() request.refresh() end)
observer:subscribe({ "media_change", "system_woke" }, function() request.refresh(true) end)
media:subscribe("mouse.clicked", function()
  sbar.exec('"$HOME/.local/bin/desktop-probe" ' .. require("helpers.shell").quote("nowplaying-cli togglePlayPause"), function(_, code)
    if code ~= 0 then media:set({ icon = { color = colors.red } })
    else request.refresh(true) end
  end)
end)
