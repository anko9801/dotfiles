local M = {}

function M.run(workspace, started, trigger)
  if type(workspace) ~= "string" or workspace == "" or workspace:find("\0", 1, true) then return false end
  if type(started) ~= "number" or started <= 0 or started % 1 ~= 0 then return false end
  trigger("aerospace_workspace_change", { FOCUSED_WORKSPACE = workspace, EVENT_START = tostring(started) })
  return true
end

return M
