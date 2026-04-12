local util = require('shebang.util')

---@class Shebang.Config
local M = {}

---@return ShebangOpts defaults
function M.get_defaults()
  return { ---@class ShebangOpts
    debug = false,
    foo = true,
    bar = false,
  }
end

---@param opts? ShebangOpts
function M.setup(opts)
  util.validate({ opts = { opts, { 'table', 'nil' }, true } })

  M.config = vim.tbl_deep_extend('keep', opts or {}, M.get_defaults())

  -- ...
  vim.g.Shebang_setup = 1 -- OPTIONAL for `health.lua`, delete if you want to
end

return M
-- vim: set ts=2 sts=2 sw=2 et ai si sta:
