local on_ac
local M = {}

function M.update(ac)
  if on_ac == ac then return end
  on_ac = ac
  sbar.set("metrics.observer", { update_freq = ac and 5 or 15 })
  sbar.set("widgets.wifi", { update_freq = ac and 10 or 30 })
  sbar.set("aerospace.observer", { update_freq = ac and 5 or 10 })
end

return M
