local wifi = sbar.add("item", "wifi", {
  position = "right",
  icon = { string = icons.wifi.connected, color = colors.mauve },
  label = { color = colors.mauve },
  background = { border_color = colors.mauve },
  update_freq = 10,
})

wifi:subscribe("mouse.clicked", function()
  wifi:set({ popup = { drawing = "toggle" } })
end)

local wifi_hostname = sbar.add("item", "wifi.hostname", {
  position = "popup.wifi",
  icon = { string = icons.wifi.hostname, color = colors.mauve },
  label = { color = colors.mauve },
  background = { drawing = false },
})

local wifi_ip = sbar.add("item", "wifi.ip", {
  position = "popup.wifi",
  icon = { string = icons.wifi.ip, color = colors.mauve },
  label = { color = colors.mauve },
  background = { drawing = false },
})

local wifi_router = sbar.add("item", "wifi.router", {
  position = "popup.wifi",
  icon = { string = icons.wifi.router, color = colors.mauve },
  label = { color = colors.mauve },
  background = { drawing = false },
})

wifi:subscribe({ "routine", "wifi_change", "system_woke" }, function()
  sbar.exec("ipconfig getifaddr en0 2>/dev/null", function(ip)
    ip = ip:gsub("%s+", "")
    if ip == "" then
      wifi:set({ icon = { string = icons.wifi.disconnected }, label = "Off" })
      wifi_hostname:set({ label = "--" })
      wifi_ip:set({ label = "--" })
      wifi_router:set({ label = "--" })
    else
      wifi:set({ icon = { string = icons.wifi.connected }, label = ip })
      wifi_ip:set({ label = ip })
      sbar.exec("hostname -s 2>/dev/null", function(hostname)
        local name = hostname:gsub("%s+", "")
        wifi_hostname:set({ label = name ~= "" and name or "N/A" })
      end)
      sbar.exec("netstat -rn 2>/dev/null | awk '/default.*en0/ {print $2; exit}'", function(router)
        local addr = router:gsub("%s+", "")
        wifi_router:set({ label = addr ~= "" and addr or "N/A" })
      end)
    end
  end)
end)
