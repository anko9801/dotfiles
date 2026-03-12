local volume = sbar.add("item", "volume", {
  position = "right",
  icon = { color = colors.green },
  label = { color = colors.green },
  background = { border_color = colors.green },
})

volume:subscribe("mouse.clicked", function()
  volume:set({ popup = { drawing = "toggle" } })
end)

local volume_device = sbar.add("item", "volume.device", {
  position = "popup.volume",
  icon = { string = icons.speaker, color = colors.green },
  label = { color = colors.green },
  background = { drawing = false },
})

volume:subscribe("volume_change", function()
  sbar.exec(
    [[osascript -e 'set v to output volume of (get volume settings)
set m to output muted of (get volume settings)
return (v as string) & "|" & (m as string)']],
    function(result)
      local vol_str, muted_str = result:match("(%d+)|(%a+)")
      local vol = tonumber(vol_str) or 0
      local muted = muted_str == "true"

      local icon
      if muted or vol == 0 then
        icon = icons.volume.mute
      elseif vol > 60 then
        icon = icons.volume.high
      elseif vol > 30 then
        icon = icons.volume.mid
      else
        icon = icons.volume.low
      end

      volume:set({
        icon = { string = icon },
        label = { string = vol .. "%" },
      })
    end
  )

  sbar.exec(
    "SwitchAudioSource -c 2>/dev/null || system_profiler SPAudioDataType 2>/dev/null"
      .. " | awk -F': ' '/Default Output Device: Yes/{found=1} found && /Device Name:/{print $2; exit}'",
    function(device)
      local name = device:gsub("%s+$", "")
      volume_device:set({ label = name ~= "" and name or "Unknown" })
    end
  )
end)
