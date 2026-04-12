local util = require('shebang.util')
local config = require('shebang.config')

---@class Shebang
local M = {}

---@param opts? ShebangOpts
function M.setup(opts)
  util.validate({ opts = { opts, { 'table', 'nil' }, true } })

  config.setup(opts or {})

  -- ...
end

return M
-- vim: set ts=2 sts=2 sw=2 et ai si sta:
