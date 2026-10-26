local module_dir = assert(arg[1])
package.cpath = module_dir .. "/?.so;" .. package.cpath
local sbar = require("sketchybar")
sbar.set_bar_name("dotfiles_isolated_execution_test")
local completed = 0
for _, fixture in ipairs({ { "printf 'value'", 0 }, { "printf 'failed'; exit 7", 7 }, { "kill -TERM $$", 143 } }) do
  local expected = fixture[2]
  sbar.exec(fixture[1], function(_, code)
    if code ~= expected then io.stderr:write("Unexpected execution status: " .. tostring(code) .. "\n"); os.exit(1) end
    completed = completed + 1
  end)
end
sbar.delay(3, function()
  if completed ~= 3 then io.stderr:write("Execution completion was not delivered\n"); os.exit(1) end
  print("Native execution: normal, failed and signaled completions delivered")
  os.exit(0)
end)
sbar.event_loop()
