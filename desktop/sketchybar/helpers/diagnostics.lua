local M = {}

function M.field(label, value)
  return label .. "\t" .. (value == nil and "—" or tostring(value))
end

function M.gib(bytes)
  return type(bytes) == "number" and string.format("%.2f GiB", bytes / 2^30) or "—"
end

function M.rate(bytes)
  if type(bytes) ~= "number" then return "—" end
  if bytes >= 2^20 then return string.format("%.2f MiB/s", bytes / 2^20) end
  return string.format("%.1f KiB/s", bytes / 2^10)
end

function M.delta(current, previous)
  if type(current) ~= "number" or type(previous) ~= "number" then return nil end
  if current >= previous then return current - previous end
end

return M
