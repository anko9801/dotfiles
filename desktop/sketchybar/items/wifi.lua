local popup_width = 250

local last_in = 0
local last_out = 0
local last_time = 0

local function format_speed(bytes_per_sec)
  if bytes_per_sec >= 1048576 then
    return string.format("%.1fM", bytes_per_sec / 1048576)
  elseif bytes_per_sec >= 1024 then
    return string.format("%.0fK", bytes_per_sec / 1024)
  else
    return string.format("%.0fB", bytes_per_sec)
  end
end

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
  sbar.exec("ipconfig getifaddr en0 2>/dev/null", function(addr_result)
    local addr = addr_result:gsub("%s+", "")
    local connected = addr ~= ""
    if not connected then
      last_in = 0
      last_out = 0
      last_time = 0
      wifi:set({
        icon = {
          string = icons.wifi.disconnected,
          color = colors.red,
        },
        label = "Off",
      })
      return
    end

    wifi:set({
      icon = {
        string = icons.wifi.connected,
        color = colors.white,
      },
    })

    sbar.exec("netstat -ib | awk '/^en0 /{print $7, $10; exit}'", function(result)
      local cur_in, cur_out = result:match("(%d+)%s+(%d+)")
      if not cur_in then
        return
      end
      cur_in = tonumber(cur_in)
      cur_out = tonumber(cur_out)

      local now = os.clock()
      if last_time > 0 then
        local elapsed = now - last_time
        if elapsed > 0 then
          local down_speed = (cur_in - last_in) / elapsed
          local up_speed = (cur_out - last_out) / elapsed
          wifi:set({
            label = icons.wifi.upload
              .. format_speed(up_speed)
              .. " "
              .. icons.wifi.download
              .. format_speed(down_speed),
          })
        end
      end

      last_in = cur_in
      last_out = cur_out
      last_time = now
    end)
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
      "networksetup -getairportnetwork en0 2>/dev/null",
      function(result)
        local name = result:match("^Current Wi%-Fi Network:%s*(.+)")
        ssid:set({ label = name or "Connected" })
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
