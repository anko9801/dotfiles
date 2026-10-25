local H = dofile("tests/sketchybar-harness.lua")
local order = assert(io.open("desktop/workspaces.json")):read("*a")
package.loaded.workspaces = {}
for key in order:gmatch('"([^"]+)"') do table.insert(package.loaded.workspaces, key) end
package.loaded["helpers.app_icons"] = { Arc = "browser" }
dofile("desktop/sketchybar/items/spaces.lua")
local function emit(event, env)
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
H.run_timer(0.1)
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
H.run_timer(0.1)
H.complete("list-windows", {})
emit("routine")
H.complete("--focused", "", 1)
assert(H.items["space.status"].props.drawing, "Unknown focus must be explicit")
H.run_timer(0.1)
H.complete("list-windows", { { workspace = "1" } })
assert(not H.items["space.1"].props.drawing, "Malformed rows must not create false empty-workspace claims")
print("SketchyBar spaces: batching, focus races, unknown state, custom workspaces and recovery passed")
