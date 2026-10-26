local H = dofile("tests/sketchybar-harness.lua")
local order = assert(io.open("desktop/workspaces.json")):read("*a")
package.loaded.workspaces = {}
for key in order:gmatch('"([^"]+)"') do table.insert(package.loaded.workspaces, key) end
package.loaded.processstamp = { birth = function() return 0 end, now = function() return 0 end }
dofile("desktop/sketchybar/items/spaces.lua")
H.complete("--focused", "1\n")
H.complete("list-windows", {})

for index = 1, 20 do
  H.emit("aerospace.observer", "aerospace_workspace_change", { FOCUSED_WORKSPACE = "2", EVENT_START = tostring(index) })
  H.emit("aerospace.observer", "front_app_switched")
  H.emit("aerospace.observer", "aerospace_windows_change")
end
assert(H.items["space.2"].props.icon.highlight, "Focus must update immediately")
assert(#H.pending == 0, "Related events must batch before starting an AeroSpace query")
assert(H.count_timers(0.1) == 1, "A burst must schedule one refresh")
H.run_timer(0.1)
assert(#H.pending == 1)
H.complete("list-windows", {})
assert(#H.pending == 0, "One query must satisfy the entire burst")

H.emit("aerospace.observer", "front_app_switched")
H.run_timer(0.1)
for _ = 1, 10 do H.emit("aerospace.observer", "aerospace_windows_change") end
H.run_timer(0.1)
assert(#H.pending == 1, "Queries must not overlap")
H.complete("list-windows", {})
assert(#H.pending == 1, "Changes during IPC get one trailing query")
H.complete("list-windows", {})

H.emit("aerospace.observer", "front_app_switched")
H.emit("aerospace.observer", "system_woke")
H.complete("--focused", "2\n")
H.complete("list-windows", {})
H.run_timer(0.1)
assert(#H.pending == 0, "Wake must invalidate a scheduled stale refresh")
print("SketchyBar refresh: immediate focus, event batching, bounded IPC, and wake recovery passed")
