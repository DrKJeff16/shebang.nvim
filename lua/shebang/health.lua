local Util = require('shebang.util')

---@class Shebang.Health
local M = {}

function M.check()
  vim.health.start('Dependencies')

  if not Util.mod_exists('Comment') then
    vim.health.error('`Comment.nvim` not installed!')
    return
  end
  vim.health.ok('`Comment.nvim` installed!')

  if Util.executable('chmod') then
    vim.health.ok('`chmod` in `PATH`!')
  else
    vim.health.warn('`chmod` not in `PATH`!')
  end
end

return M
-- vim: set ts=2 sts=2 sw=2 et ai si sta:
