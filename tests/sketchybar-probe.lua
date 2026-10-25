local H = dofile("tests/sketchybar-harness.lua")
local probe = require("helpers.probe")
local displayed, reason
local request = probe.new({
  command = "fixture", max_age = 20,
  apply = function(value)
    if not probe.number(value, 0, 100) then return false end
    displayed = value
    return true
  end,
  unavailable = function(value) displayed, reason = nil, value end,
})
request.refresh()
for _ = 1, 100 do request.refresh() end
assert(#H.pending == 1)
H.complete("fixture", 10)
assert(displayed == 10 and #H.pending == 1)
request.refresh(true)
assert(displayed == nil)
H.complete("fixture", 20)
assert(displayed == nil and #H.pending == 1, "Reset discards old responses")
H.complete("fixture", 30)
assert(displayed == 30)
H.run_timer(20)
assert(displayed == 30, "Old expiry must not erase a new sample")
H.run_timer(20)
assert(displayed == nil and reason == "更新停止")
for _, value in ipairs({ 0/0, math.huge, -1, 101, "10", {} }) do
  request.refresh()
  H.complete("fixture", value)
  assert(displayed == nil and reason == "取得不可")
end
request.refresh()
H.complete("fixture", "timeout", 124)
assert(displayed == nil)
request.refresh()
assert(request.accept(50))
H.complete("fixture", 40)
assert(displayed == 50, "Authoritative event cancels an earlier query")
request.invalidate()
assert(displayed == nil)
print("SketchyBar probe: coalescing, stale responses, expiry, invalid data and timeout passed")
