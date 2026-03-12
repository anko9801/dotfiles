local popup_width = 250

local wifi = sbar.add("item", "widgets.wifi", {
  position = "right",
  icon = {
    string = icons.wifi.connected,
    color = colors.white,
  },
  label = {
    string = "...",
    font = { family = settings.font.numbers },
  },
  background = { drawing = false },
  update_freq = 10,
  popup = { align = "center", height = 30 },
})

local ssid = sbar.add("item", {
  position = "popup." .. wifi.name,
  icon = {
    font = { style = settings.font.style_map["Bold"] },
    string = icons.wifi.router,
  },
  width = popup_width,
  align = "center",
  label = {
    font = {
      size = 15,
      style = settings.font.style_map["Bold"],
    },
    max_chars = 18,
    string = "????????????",
  },
  background = {
    height = 2,
    color = colors.grey,
    y_offset = -15,
  },
})

local hostname = sbar.add("item", {
  position = "popup." .. wifi.name,
  icon = {
    align = "left",
    string = "Hostname:",
    width = popup_width / 2,
  },
  label = {
    max_chars = 20,
    string = "????????????",
    width = popup_width / 2,
    align = "right",
  },
})

local ip = sbar.add("item", {
  position = "popup." .. wifi.name,
  icon = {
    align = "left",
    string = "IP:",
    width = popup_width / 2,
  },
  label = {
    string = "???.???.???.???",
    width = popup_width / 2,
    align = "right",
  },
})

local router = sbar.add("item", {
  position = "popup." .. wifi.name,
  icon = {
    align = "left",
    string = "Router:",
    width = popup_width / 2,
  },
  label = {
    string = "???.???.???.???",
    width = popup_width / 2,
    align = "right",
  },
})

wifi:subscribe({ "routine", "wifi_change", "system_woke" }, function()
  sbar.exec("ipconfig getifaddr en0 2>/dev/null", function(result)
    local addr = result:gsub("%s+", "")
    local connected = addr ~= ""
    wifi:set({
      icon = {
        string = connected and icons.wifi.connected or icons.wifi.disconnected,
        color = connected and colors.white or colors.red,
      },
      label = connected and addr or "Off",
    })
  end)
end)

local function hide_details()
  wifi:set({
    popup = { drawing = false },
    background = { drawing = false },
  })
end

local function toggle_details()
  local should_draw = wifi:query().popup.drawing == "off"
  if should_draw then
    wifi:set({
      popup = { drawing = true },
      background = { drawing = true, color = colors.bar.bg, border_width = 0 },
    })
    sbar.exec("networksetup -getcomputername 2>/dev/null", function(result)
      hostname:set({ label = result })
    end)
    sbar.exec("ipconfig getifaddr en0 2>/dev/null", function(result)
      ip:set({ label = result })
    end)
    sbar.exec(
      "ipconfig getsummary en0 2>/dev/null | awk -F ' SSID : '  '/ SSID : / {print $2}'",
      function(result)
        ssid:set({ label = result })
      end
    )
    sbar.exec(
      "networksetup -getinfo Wi-Fi 2>/dev/null | awk -F 'Router: ' '/^Router: / {print $2}'",
      function(result)
        router:set({ label = result })
      end
    )
  else
    hide_details()
  end
end

wifi:subscribe("mouse.clicked", toggle_details)
wifi:subscribe("mouse.exited.global", hide_details)

local function copy_label_to_clipboard(env)
  local label = sbar.query(env.NAME).label.value
  sbar.exec('echo "' .. label .. '" | pbcopy')
  sbar.set(env.NAME, { label = { string = icons.clipboard, align = "center" } })
  sbar.delay(1, function()
    sbar.set(env.NAME, { label = { string = label, align = "right" } })
  end)
end

ssid:subscribe("mouse.clicked", copy_label_to_clipboard)
hostname:subscribe("mouse.clicked", copy_label_to_clipboard)
ip:subscribe("mouse.clicked", copy_label_to_clipboard)
router:subscribe("mouse.clicked", copy_label_to_clipboard)
