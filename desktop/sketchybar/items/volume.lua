local shell = require("helpers.shell")
local popup_width = 250
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
  popup = { align = "center" },
  update_freq = 30,
})

local volume_slider = sbar.add("slider", popup_width, {
  position = "popup." .. volume.name,
  slider = {
    highlight_color = colors.blue,
    background = {
      height = 6,
      corner_radius = 3,
      color = colors.bg2,
    },
    knob = {
      string = "●",
      drawing = true,
    },
  },
  background = { color = colors.bg1, height = 2, y_offset = -20 },
  click_script = 'osascript -e "set volume output volume $PERCENTAGE"',
})

local details = sbar.add("item", "widgets.volume.details", {
  position = "popup." .. volume.name,
  icon = { drawing = false },
  label = { string = "取得待ち" },
})

local request = probe.new({
  command = '"$HOME/.local/bin/desktop-audio"',
  max_age = 65,
  unavailable = function(reason)
    volume:set({ icon = { string = "?", color = colors.grey }, label = "—" })
    volume_slider:set({ drawing = false })
    details:set({ label = reason })
  end,
  apply = function(result)
    if type(result) ~= "table" or not probe.number(result.device, 1) then return false end
    if result.volume == nil then
      volume:set({ icon = { string = icons.volume._100, color = colors.grey }, label = "外部" })
      volume_slider:set({ drawing = false })
      details:set({ label = "この出力の音量はOSから取得・調整できません" })
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
    volume_slider:set({ drawing = true, slider = { percentage = vol } })
    details:set({ label = (result.muted and "ミュート中 · 設定音量" .. vol .. "%" or "出力音量" .. vol .. "%")
      .. " · " .. os.date("%H:%M:%S") .. "取得" })
    return true
  end,
})
volume:subscribe({ "forced", "routine" }, function() request.refresh() end)
volume:subscribe("system_woke", function() request.refresh(true) end)

local device_request = 0
volume:subscribe("volume_change", function()
  device_request = device_request + 1
  sbar.remove("/volume.device\\..*/")
  request.refresh(true)
end)

local function volume_collapse_details()
  device_request = device_request + 1
  local drawing = volume:query().popup.drawing == "on"
  if not drawing then return end
  volume:set({
    popup = { drawing = false },
    background = { drawing = false },
  })
  sbar.remove("/volume.device\\..*/")
end

local current_audio_device = "None"
local function volume_toggle_details(env)
  if env.BUTTON == "right" then
    sbar.exec("open /System/Library/PreferencePanes/Sound.prefpane")
    return
  end

  local should_draw = volume:query().popup.drawing == "off"
  if should_draw then
    volume:set({
      popup = { drawing = true },
      background = { drawing = true, color = colors.bar.bg, border_width = 0 },
    })
    request.refresh()
    sbar.remove("/volume.device\\..*/")
    device_request = device_request + 1
    local request = device_request
    sbar.exec('"$HOME/.local/bin/desktop-probe" ' .. shell.quote("SwitchAudioSource -t output -c"), function(result, code)
      if code ~= 0 or type(result) ~= "string" or request ~= device_request then return end
      current_audio_device = result:gsub("%s+$", "")
      sbar.exec('"$HOME/.local/bin/desktop-probe" ' .. shell.quote("SwitchAudioSource -a -t output"), function(available, exit_code)
        if exit_code ~= 0 or type(available) ~= "string" or request ~= device_request then return end
        local counter = 0
        for device in string.gmatch(available, "[^\r\n]+") do
          local color = colors.grey
          if current_audio_device == device then
            color = colors.pure_white
          end
          sbar.add("item", "volume.device." .. counter, {
            position = "popup." .. volume.name,
            width = popup_width,
            align = "center",
            label = { string = device, color = color },
            click_script = 'SwitchAudioSource -t output -s '
              .. shell.quote(device)
              .. ' && sketchybar --trigger volume_change',
          })
          counter = counter + 1
        end
      end)
    end)
  else
    volume_collapse_details()
  end
end

local function volume_scroll(env)
  if type(env.INFO) ~= "table" then return end
  local delta = tonumber(env.INFO.delta)
  if not delta then return end
  if not (env.INFO.modifier == "ctrl") then
    delta = delta * 10.0
  end
  sbar.exec(
    'osascript -e "set volume output volume (output volume of (get volume settings) + ' .. delta .. ')"'
  )
end

volume:subscribe("mouse.clicked", volume_toggle_details)
volume:subscribe("mouse.scrolled", volume_scroll)
volume:subscribe("mouse.exited.global", volume_collapse_details)
