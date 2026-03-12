local popup_width = 250

local volume = sbar.add("item", "widgets.volume", {
  position = "right",
  icon = {
    string = icons.volume._100,
    color = colors.grey,
    font = {
      style = settings.font.style_map["Regular"],
      size = 14.0,
    },
  },
  label = {
    string = "??%",
    font = { family = settings.font.numbers },
  },
  background = { drawing = false },
  popup = { align = "center" },
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

volume:subscribe("volume_change", function(env)
  local vol = tonumber(env.INFO)
  local icon = icons.volume._0
  if vol > 60 then
    icon = icons.volume._100
  elseif vol > 30 then
    icon = icons.volume._66
  elseif vol > 10 then
    icon = icons.volume._33
  elseif vol > 0 then
    icon = icons.volume._10
  end

  local lead = ""
  if vol < 10 then
    lead = "0"
  end

  volume:set({
    icon = { string = icon },
    label = { string = lead .. vol .. "%" },
  })
  volume_slider:set({ slider = { percentage = vol } })
end)

local function volume_collapse_details()
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
    sbar.exec("SwitchAudioSource -t output -c 2>/dev/null", function(result)
      current_audio_device = result:sub(1, -2)
      sbar.exec("SwitchAudioSource -a -t output 2>/dev/null", function(available)
        local counter = 0
        for device in string.gmatch(available, "[^\r\n]+") do
          local color = colors.grey
          if current_audio_device == device then
            color = colors.white
          end
          sbar.add("item", "volume.device." .. counter, {
            position = "popup." .. volume.name,
            width = popup_width,
            align = "center",
            label = { string = device, color = color },
            click_script = 'SwitchAudioSource -s "'
              .. device
              .. '" && sketchybar --set /volume.device\\.*/ label.color='
              .. colors.grey
              .. " --set $NAME label.color="
              .. colors.white,
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
  local delta = env.INFO.delta
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
