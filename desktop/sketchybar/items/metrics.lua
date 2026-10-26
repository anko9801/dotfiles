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
    for _, key in ipairs({ "memory_bytes", "total_bytes", "anonymous_bytes", "purgeable_bytes", "wired_bytes", "compressed_bytes",
      "file_backed_bytes", "page_size", "swapin_pages", "swapout_pages", "logical_cpus", "physical_cpus", "swap_total_gib" }) do
      if result[key] ~= nil and not probe.number(result[key], 0, 2^53) then return false end
      if result[key] ~= nil and key ~= "swap_total_gib" and result[key] % 1 ~= 0 then return false end
    end
    if result.load_average ~= nil then
      if type(result.load_average) ~= "table" or #result.load_average ~= 3 then return false end
      for _, value in ipairs(result.load_average) do if not probe.number(value, 0) then return false end end
    end
    for _, state in ipairs({ "user", "system", "nice", "idle" }) do
      if not probe.number(result[state], 0, 2^32 - 1) or result[state] % 1 ~= 0 then return false end
    end
    local elapsed = previous and result.monotonic - previous.monotonic or 0
    local memory_sample = {}
    for key, value in pairs(result) do memory_sample[key] = value end
    local diagnostic = require("helpers.diagnostics")
    if previous and elapsed > 0 and elapsed <= 45 and result.page_size and result.page_size == previous.page_size then
      local incoming = diagnostic.delta(result.swapin_pages, previous.swapin_pages)
      local outgoing = diagnostic.delta(result.swapout_pages, previous.swapout_pages)
      memory_sample.swap_in_pages_per_second = incoming and incoming / elapsed
      memory_sample.swap_out_pages_per_second = outgoing and outgoing / elapsed
    end
    memory_sample.interval = elapsed > 0 and elapsed <= 45 and elapsed or nil
    memory.update(result.memory_percent, result.pressure, result.swap_gib, memory_sample)
    if previous and elapsed > 0 and elapsed <= 45 then
      local busy, total, portions = 0, 0, {}
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
        portions[state] = delta
        if state ~= "idle" then busy = busy + delta end
      end
      if total > 0 then
        local cpu_sample = { monotonic = result.monotonic, logical_cpus = result.logical_cpus,
          physical_cpus = result.physical_cpus, load_average = result.load_average }
        for state, value in pairs(portions) do cpu_sample[state] = 100 * value / total end
        cpu.update(100 * busy / total, elapsed, cpu_sample)
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
