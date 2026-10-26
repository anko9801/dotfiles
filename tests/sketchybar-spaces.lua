local H = dofile("tests/sketchybar-harness.lua")
local order = assert(io.open("desktop/workspaces.json")):read("*a")
package.loaded.workspaces = {}
for key in order:gmatch('"([^"]+)"') do table.insert(package.loaded.workspaces, key) end
package.loaded["helpers.app_icons"] = { Arc = "browser" }
local clock_now = 100
package.loaded.processstamp = { birth = function() return 100 end, now = function() return clock_now end }
dofile("desktop/sketchybar/items/spaces.lua")
local event_start = 100
local function emit(event, env)
  if event == "aerospace_workspace_change" and env.EVENT_START == nil then
    event_start = event_start + 1
    env.EVENT_START = tostring(event_start)
    clock_now = event_start
  end
  H.emit("aerospace.observer", event, env)
end
H.complete("--focused", "1\n")
local windows = {
  { workspace = "1", ["app-name"] = "Arc" },
  { workspace = "1", ["app-name"] = "Arc" },
  { workspace = "2", ["app-name"] = "Unknown App" },
}
H.complete("list-windows", windows)
assert(H.items["space.1"].props.label.string == "browser")
assert(H.items["space.2"].props.icon.string == "2 Unknown App")
assert(not H.items["space.3"].props.drawing)
emit("aerospace_workspace_change", { FOCUSED_WORKSPACE = "2" })
assert(H.items["space.2"].props.icon.highlight, "Focus updates before IPC")
assert(#H.pending == 0 and H.count_timers(0.1) == 0, "Workspace focus alone must not enumerate windows")
emit("front_app_switched", { INFO = "Unknown App" })
H.run_timer(0.1)
assert(#H.pending == 0, "Known applications must not enumerate windows")
emit("front_app_switched", { INFO = "Arc" })
emit("aerospace_workspace_change", { FOCUSED_WORKSPACE = "1" })
H.run_timer(0.1)
assert(#H.pending == 0, "Check cached membership after the workspace event arrives")
for _ = 1, 20 do
  emit("front_app_switched", { INFO = "Arc" })
  emit("aerospace_workspace_change", { FOCUSED_WORKSPACE = "1" })
end
assert(H.count_timers(0.1) == 1, "Coalesce focus bursts")
H.run_timer(0.1)
assert(#H.pending == 0, "Focus bursts must not compete with keyboard commands")
emit("front_app_switched", { INFO = "New App" })
H.run_timer(0.1)
H.complete("list-windows", windows)
emit("aerospace_windows_change")
emit("front_app_switched", { INFO = "Arc" })
H.run_timer(0.1)
H.complete("list-windows", windows)
emit("aerospace_workspace_change", { FOCUSED_WORKSPACE = "2" })
emit("routine")
emit("front_app_switched", { INFO = "Unknown App" })
H.run_timer(0.1)
H.complete("--focused", "2\n")
H.complete("list-windows", windows)
local writes = H.items["space.1"].writes + H.items["space.2"].writes
emit("routine")
H.run_timer(0.1)
H.complete("--focused", "2\n")
H.complete("list-windows", windows)
assert(H.items["space.1"].writes + H.items["space.2"].writes == writes)
emit("routine")
H.run_timer(0.1)
H.complete("--focused", "2\n")
H.complete("list-windows", "Connection failed", 1)
assert(not H.items["space.1"].props.drawing)
assert(H.items["space.2"].props.label.drawing == false)
assert(H.items["space.2"].props.icon.string == "2 —", "Failure clears stale app icons")
emit("system_woke")
emit("aerospace_workspace_change", { FOCUSED_WORKSPACE = "5" })
H.complete("--focused", "4\n")
assert(H.items["space.5"].props.icon.highlight, "Wake response cannot overwrite newer event")
H.complete("list-windows", {})
H.run_timer(0.1)
H.complete("list-windows", {})
emit("aerospace_workspace_change", { FOCUSED_WORKSPACE = "custom" })
assert(H.items["space.other"].props.drawing and H.items["space.other"].props.icon.string == "custom")
assert(H.count_timers(0.1) == 0, "Custom workspace focus must not enumerate unchanged windows")
emit("routine")
H.complete("--focused", "", 1)
assert(H.items["space.status"].props.drawing, "Unknown focus must be explicit")
H.run_timer(0.1)
H.complete("list-windows", { { workspace = "1" } })
assert(not H.items["space.1"].props.drawing, "Malformed rows must not create false empty-workspace claims")
emit("routine")
H.run_timer(0.1)
H.complete("--focused", "1\n")
H.complete("list-windows", windows)
emit("aerospace_workspace_change", { FOCUSED_WORKSPACE = "2" })
emit("aerospace_workspace_change", { FOCUSED_WORKSPACE = "5", EVENT_START = "100" })
assert(H.items["space.2"].props.icon.highlight, "A pre-reload notification cannot overwrite current focus")
emit("aerospace_workspace_change", { FOCUSED_WORKSPACE = "5", EVENT_START = tostring(event_start - 1) })
assert(H.items["space.2"].props.icon.highlight, "A delayed callback cannot overwrite newer focus")
emit("aerospace_workspace_change", { FOCUSED_WORKSPACE = "5", EVENT_START = tostring(event_start) })
assert(H.items["space.2"].props.icon.highlight, "Duplicate events must be ignored")
for _, stamp in ipairs({ "bad", "inf", "nan", "-1", "0", "100.5", "" }) do
  emit("aerospace_workspace_change", { FOCUSED_WORKSPACE = "5", EVENT_START = stamp })
  assert(H.items["space.2"].props.icon.highlight, "Invalid timestamps cannot change focus")
end
clock_now = event_start + 2
emit("routine")
emit("aerospace_workspace_change", { FOCUSED_WORKSPACE = "5", EVENT_START = tostring(event_start + 1) })
H.complete("--focused", "2\n")
assert(H.items["space.2"].props.icon.highlight, "Notifications predating reconciliation cannot supersede its result")
H.run_timer(0.1)
H.complete("list-windows", windows)
print("SketchyBar spaces: query suppression, batching, ordered notifications, focus races and recovery passed")
