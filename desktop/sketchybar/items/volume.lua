local probe = require("helpers.probe")

local volume = sbar.add("item", "widgets.volume", {
  position = "right",
  icon = {
    string = icons.volume._100,
    color = colors.pure_white,
    font = {
      style = settings.font.style_map["Regular"],
      size = 14.0,
    },
    padding_right = 4,
  },
  label = {
    string = "—",
    width = 39,
    font = { family = settings.font.numbers },
  },
  background = { drawing = false },
  update_freq = 30,
})

local request = probe.new({
  command = '"$HOME/.local/bin/desktop-audio"',
  max_age = 65,
  unavailable = function(reason)
    volume:set({ icon = { string = "?", color = colors.grey }, label = "—" })
  end,
  apply = function(result)
    if type(result) ~= "table" or not probe.number(result.device, 1) then return false end
    if result.volume == nil then
      volume:set({ icon = { string = icons.volume._100, color = colors.grey }, label = "—" })
      return true
    end
    if not probe.number(result.volume, 0, 100) or type(result.muted) ~= "boolean" then return false end
    local vol = math.floor(result.volume + 0.5)
    local icon = icons.volume._0
    if not result.muted then
      if vol > 60 then icon = icons.volume._100
      elseif vol > 30 then icon = icons.volume._66
      elseif vol > 0 then icon = icons.volume._33 end
    end
    volume:set({ icon = { string = icon, color = colors.pure_white }, label = result.muted and "消音" or vol .. "%" })
    return true
  end,
})
volume:subscribe({ "forced", "routine" }, function() request.refresh() end)
volume:subscribe("system_woke", function() request.refresh(true) end)

volume:subscribe("volume_change", function() request.refresh(true) end)
volume:subscribe("mouse.clicked", function()
  sbar.exec("open /System/Library/PreferencePanes/Sound.prefPane")
end)
