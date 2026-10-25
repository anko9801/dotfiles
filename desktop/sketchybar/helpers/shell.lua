local M = {}

function M.quote(value)
  return "'" .. tostring(value):gsub("'", "'\\''") .. "'"
end

return M
