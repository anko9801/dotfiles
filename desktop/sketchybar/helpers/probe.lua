local shell = require("helpers.shell")
local M = {}

function M.number(value, minimum, maximum)
  return type(value) == "number" and value == value and value > -math.huge and value < math.huge
    and (minimum == nil or value >= minimum) and (maximum == nil or value <= maximum)
end

function M.new(options)
  local running, pending = false, false
  local epoch, freshness = 0, 0
  local function unavailable(reason)
    freshness = freshness + 1
    options.unavailable(reason)
  end
  local function accept(result)
    local ok, valid = pcall(options.apply, result)
    if not ok or valid ~= true then unavailable("取得不可"); return false end
    freshness = freshness + 1
    local stamp = freshness
    sbar.delay(options.max_age, function()
      if stamp == freshness then unavailable("更新停止") end
    end)
    return true
  end
  local function invalidate(reason)
    epoch = epoch + 1
    pending = false
    unavailable(reason or "更新待ち")
  end
  local refresh
  refresh = function(reset)
    if reset then
      invalidate()
    end
    if running then pending = true; return end
    running = true
    if options.before then options.before() end
    local current = epoch
    sbar.exec('"$HOME/.local/bin/desktop-probe" ' .. shell.quote(options.command), function(result, code)
      running = false
      if current == epoch then
        if code == 0 then accept(result) else unavailable("取得不可") end
      end
      if pending then pending = false; refresh() end
    end)
  end
  return {
    refresh = refresh,
    invalidate = invalidate,
    accept = function(result)
      epoch = epoch + 1
      pending = false
      return accept(result)
    end,
  }
end

return M
