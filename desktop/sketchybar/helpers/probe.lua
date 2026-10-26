local shell = require("helpers.shell")
local M = {}

function M.number(value, minimum, maximum)
  return type(value) == "number" and value == value and value > -math.huge and value < math.huge
    and (minimum == nil or value >= minimum) and (maximum == nil or value <= maximum)
end

function M.new(options)
  local running, pending = nil, false
  local sequence, missing = 0, 0
  local epoch, freshness = 0, 0
  local function unavailable(reason)
    freshness = freshness + 1
    options.unavailable(reason)
  end
  local function accept(result, started)
    local ok, valid = pcall(options.apply, result, started)
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
    sequence = sequence + 1
    local identity = sequence
    running = identity
    local started = options.before and options.before()
    local current = epoch
    local function complete(result, code)
      if running ~= identity then return end
      running, missing = nil, 0
      if current == epoch then
        if code == 0 then accept(result, started) else unavailable("取得不可") end
      end
      if pending then pending = false; refresh() end
    end
    local launched = sbar.exec('"$HOME/.local/bin/desktop-probe" ' .. shell.quote(options.command), complete)
    local function lost()
      if running ~= identity then return end
      local wanted = pending
      running, pending = nil, false
      if current ~= epoch then
        if wanted then refresh() end
        return
      end
      epoch, missing = epoch + 1, missing + 1
      unavailable("応答期限切れ")
      local generation = epoch
      sbar.delay(math.min(2 ^ (missing - 1), 30), function()
        if epoch == generation and sequence == identity and not running then refresh() end
      end)
    end
    if launched == false then lost()
    else
      -- The native worker has a 10s lifetime; wrapped commands get 4s plus 1s grace.
      sbar.delay(16, lost)
    end
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
