local module_dir = assert(arg[1], "Pass the directory containing sketchybar.so")
package.cpath = module_dir .. "/?.so;" .. package.cpath
local sbar = require("sketchybar")
sbar.set_bar_name("dotfiles_isolated_lifetime_test")
local function references()
  local count = 0
  for _, value in pairs(debug.getregistry()) do
    if type(value) == "function" then count = count + 1 end
  end
  return count
end
local initial, completed = references(), 0
for index = 1, 200 do
  local value = { index = index }
  sbar.delay(0.01, function() assert(value.index > 0); completed = completed + 1 end)
end
sbar.delay(0.1, function()
  collectgarbage("collect"); collectgarbage("collect")
  local retained = references() - initial
  print(string.format("completed=%d retained=%d", completed, retained))
  if completed ~= 200 or retained > 1 then
    io.stderr:write("Completed timer references must be released\n")
    os.exit(1)
  end
  os.exit(0)
end)
sbar.event_loop()
