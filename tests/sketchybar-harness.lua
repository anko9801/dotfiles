local H = { items = {}, pending = {}, timers = {}, timer_delays = {}, animations = 0, time = 100 }
local function merge(target, values)
  for key, value in pairs(values) do
    if (key == "label" or key == "icon") and type(value) == "string" then value = { string = value } end
    if type(value) == "table" and type(target[key]) == "table" then
      merge(target[key], value)
    else
      target[key] = value
    end
  end
end

package.path = "desktop/sketchybar/?.lua;" .. package.path
package.preload.processstamp = function()
  return { pid = function() return 321 end, birth = function() return 987 end, now = function() return 10000 end,
    monotonic = function() return H.time end }
end
colors = { bar = { bg = 1 }, popup = {}, with_alpha = function() return 1 end }
setmetatable(colors, { __index = function(_, key) return key end })
icons = dofile("desktop/sketchybar/icons.lua")
settings = dofile("desktop/sketchybar/settings.lua")
sbar = {
  add = function(kind, a, b, c)
    if kind == "event" then return end
    local name = type(a) == "string" and a or "item_" .. #H.items
    local props = c or (type(b) == "table" and b) or (type(a) == "table" and a) or {}
    local item = { name = name, props = {}, handlers = {}, points = {}, writes = 0 }
    merge(item.props, props)
    function item:set(values)
      self.writes = self.writes + 1
      merge(self.props, values)
    end
    function item:subscribe(events, callback)
      if type(events) == "string" then events = { events } end
      for _, event in ipairs(events) do self.handlers[event] = callback end
    end
    function item:push(values) self.points[#self.points + 1] = values[1] end
    function item:query()
      return {
        popup = { drawing = self.props.popup and self.props.popup.drawing == true and "on" or "off" },
        label = { value = self.props.label and self.props.label.string },
      }
    end
    H.items[#H.items + 1] = item
    H.items[name] = item
    return item
  end,
  exec = function(command, callback)
    H.pending[#H.pending + 1] = { command = command, callback = callback }
  end,
  delay = function(delay, callback)
    H.timers[#H.timers + 1] = callback
    H.timer_delays[#H.timer_delays + 1] = delay
  end,
  animate = function(_, _, callback) H.animations = H.animations + 1; callback() end,
  query = function(name) return H.items[name]:query() end,
  set = function(name, values) H.items[name]:set(values) end,
  remove = function() end,
}
function H.complete(pattern, result, code)
  for i, request in ipairs(H.pending) do
    if request.command:find(pattern, 1, true) then
      table.remove(H.pending, i)
      if request.callback then request.callback(result, code or 0) end
      return request.command
    end
  end
  error("No pending request: " .. pattern)
end
function H.run_timer(delay)
  for i, value in ipairs(H.timer_delays) do
    if value == delay then
      table.remove(H.timer_delays, i)
      table.remove(H.timers, i)()
      return
    end
  end
  error("No timer: " .. delay)
end
function H.count_timers(delay)
  local count = 0
  for _, value in ipairs(H.timer_delays) do if value == delay then count = count + 1 end end
  return count
end
function H.emit(item, event, env)
  env = env or {}
  env.SENDER = event
  H.items[item].handlers[event](env)
end
io.popen = function() error("Blocking subprocess on the SketchyBar event thread") end
os.time = function() return H.time end
return H
