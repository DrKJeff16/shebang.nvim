local Util = require('shebang.util')

---@class ShebangOpts
---Whether to add a `/usr/bin/env` by default.
--- ---
---Default: `false`
--- ---
---@field env? boolean

---@class ShebangDefaultOpts: ShebangOpts
---@field env boolean

---@class Shebang.Config
---@field config ShebangOpts
local M = {}

M.config = {}

---@return ShebangDefaultOpts defaults
function M.get_defaults()
  ---@type ShebangDefaultOpts
  return {
    env = false,
  }
end

---@param opts? ShebangOpts
function M.setup(opts)
  Util.validate({ opts = { opts, { 'table', 'nil' }, true } })

  M.config = vim.tbl_deep_extend('keep', opts or {}, M.get_defaults())
  vim.g.shebang_setup = 1
end

return M
-- vim: set ts=2 sts=2 sw=2 et ai si sta:
