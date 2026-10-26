local shell = require("helpers.shell")
local M = {}
local channel, stamp, last_launch
local serial = 0

local function launch()
  if last_launch and os.time() - last_launch < 2 then return end
  last_launch = os.time()
  sbar.exec('"$HOME/.config/sketchybar/helpers/native-menu" --serve '
    .. stamp.pid() .. " " .. shell.quote(channel))
end

function M.start()
  if channel then return end
  stamp = require("processstamp")
  channel = "pub.anko.sketchybar-menu." .. stamp.pid() .. "." .. stamp.birth()
  launch()
end

function M.bind(items, kind, contents)
  for _, item in ipairs(items) do
    item:subscribe("mouse.clicked", function()
      M.start()
      serial = serial + 1
      local request = serial
      local arguments = { '"$HOME/.config/sketchybar/helpers/menu-client"', shell.quote(channel),
        tostring(stamp.now()), shell.quote(kind) }
      for _, line in ipairs(contents()) do arguments[#arguments + 1] = shell.quote(line) end
      local function send(attempt)
        sbar.exec(table.concat(arguments, " "), function(_, code)
          -- Only a missing endpoint is safe to retry; a timed-out send may have opened the menu.
          if code == 69 and attempt < 4 and request == serial then
            launch()
            sbar.delay(0.1 * attempt, function() if request == serial then send(attempt + 1) end end)
          end
        end)
      end
      send(1)
    end)
  end
end

return M
