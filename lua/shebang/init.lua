local Util = require('shebang.util')

---@generic T: table, F
---@param t T
---@param k any
---@param fallback F
---@return F fallback
local function get(t, k, fallback)
  return Util.get(t, k, function()
    return Util.rawset(t, k, fallback)
  end, true)
end

---@class Shebang
---@field config Shebang.Config
---@field core Shebang.Core
---@field health Shebang.Health
---@field setup (fun())|(fun(opts: ShebangOpts))
---@field util Shebang.Util
local M = {}

setmetatable(M, {
  __index = function(self, k) ---@param self Shebang
    local raw = Util.get(self, k)
    if raw ~= nil then
      return raw
    end

    if type(k) ~= 'string' then
      return
    end

    ---@cast k string
    if Util.mod_exists('shebang.' .. k) then
      return get(self, k, require('shebang.' .. k))
    end
    if k == 'setup' then
      return get(self, k, self.config.setup)
    end
  end,
})

return M
-- vim: set ts=2 sts=2 sw=2 et ai si sta:
