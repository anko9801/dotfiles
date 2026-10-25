local cpu = require("items.cpu")
local memory = require("items.memory")
local probe = require("helpers.probe")
local previous
local request

local observer = sbar.add("item", "metrics.observer", {
  drawing = false,
  updates = true,
  update_freq = 5,
})

request = probe.new({
  command = '"$HOME/.local/bin/desktop-metrics"',
  max_age = 45,
  unavailable = function(reason)
    previous = nil
    cpu.unavailable(reason)
    memory.unavailable(reason)
  end,
  apply = function(result)
    if type(result) ~= "table" or not probe.number(result.memory_percent, 0, 100)
      or not probe.number(result.swap_gib, -1) or not probe.number(result.monotonic, 0) then return false end
    if not ({ [0] = true, [1] = true, [2] = true, [4] = true })[result.pressure] then return false end
    for _, state in ipairs({ "user", "system", "nice", "idle" }) do
      if not probe.number(result[state], 0, 2^32 - 1) or result[state] % 1 ~= 0 then return false end
    end
    memory.update(result.memory_percent, result.pressure, result.swap_gib)
    local elapsed = previous and result.monotonic - previous.monotonic or 0
    if previous and elapsed > 0 and elapsed <= 45 then
      local busy, total = 0, 0
      for _, state in ipairs({ "user", "system", "nice", "idle" }) do
        local delta = result[state] - previous[state]
        if delta < 0 then
          if previous[state] < 2^32 - 1000000 or result[state] > 1000000 then
            cpu.unavailable("CPUカウンター再計測中")
            previous = result
            return true
          end
          delta = delta + 2^32
        end
        total = total + delta
        if state ~= "idle" then busy = busy + delta end
      end
      if total > 0 then cpu.update(100 * busy / total, elapsed)
      else cpu.unavailable("CPU区間を計測中") end
    else
      cpu.unavailable("CPU区間を計測中")
      sbar.delay(1, function() request.refresh() end)
    end
    previous = result
    return true
  end,
})

observer:subscribe({ "routine", "forced" }, function() request.refresh() end)
observer:subscribe("system_woke", function() request.refresh(true) end)
