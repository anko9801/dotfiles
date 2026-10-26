local notify = dofile("desktop/aerospace-notify.lua")
local sent = {}
local function trigger(event, env) sent[#sent + 1] = { event, env } end
assert(notify.run("V", 12345678901234, trigger))
assert(sent[1][1] == "aerospace_workspace_change")
assert(sent[1][2].FOCUSED_WORKSPACE == "V")
assert(sent[1][2].EVENT_START == "12345678901234")
for _, workspace in ipairs({ "", "a\0b", false }) do assert(not notify.run(workspace, 1, trigger)) end
for _, stamp in ipairs({ 0, -1, 1.5, math.huge, 0/0, "1" }) do assert(not notify.run("V", stamp, trigger)) end
assert(not notify.run(nil, 1, trigger))
assert(#sent == 1, "Malformed notifications must not be published")
print("SketchyBar native notifier: environment validation and timestamp preservation passed")
