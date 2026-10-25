local H = dofile("tests/sketchybar-harness.lua")
local clock = { month = 10, day = 25, wday = 1, hour = 9, min = 4 }
local reads = 0
os.date = function(format, timestamp)
  assert(format == "*t" and timestamp == H.time)
  reads = reads + 1
  return clock
end
dofile("desktop/sketchybar/items/calendar.lua")
local cal = H.items["widgets.calendar"]
H.emit(cal.name, "forced")
assert(cal.props.label.string == "9:04" and cal.props.icon.string == "10月25日 (日)")
assert(reads == 1, "Date and time must share one snapshot")
local writes = cal.writes
H.emit(cal.name, "routine")
assert(cal.writes == writes, "Unchanged text must not redraw")
clock.hour, clock.min = 8, 30
H.emit(cal.name, "routine")
assert(cal.props.label.string == "8:30", "Clock adjustments must update on the next tick")
clock.day, clock.wday, clock.hour, clock.min = 26, 2, 0, 0
H.emit(cal.name, "system_woke")
assert(cal.props.icon.string == "10月26日 (月)" and cal.props.label.string == "0:00")
assert(#H.pending == 0 and #H.timers == 0 and cal.props.update_freq == 1)
print("SketchyBar calendar: coherent snapshot, clock changes, midnight, cached rendering passed")
