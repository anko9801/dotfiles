local shell = require("helpers.shell")
local M = {}

function M.bind(items, kind, contents)
  for _, item in ipairs(items) do
    item:subscribe("mouse.clicked", function()
      local arguments = { '"$HOME/.config/sketchybar/helpers/native-menu"', shell.quote(kind) }
      for _, line in ipairs(contents()) do arguments[#arguments + 1] = shell.quote(line) end
      sbar.exec(table.concat(arguments, " "))
    end)
  end
end

return M
