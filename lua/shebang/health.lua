---@class Shebang.Health
local M = {}

function M.check()
  local Util = require('shebang.util')

  vim.health.start('Dependencies')
  if Util.mod_exists('Comment') then
    vim.health.ok('`Comment.nvim` installed!')
    if Util.executable('chmod') then
      vim.health.ok('`chmod` in `PATH`!')
    else
      vim.health.warn('`chmod` not in `PATH`!')
    end
  else
    vim.health.error('`Comment.nvim` not installed!')
  end
end

return M
-- vim: set ts=2 sts=2 sw=2 et ai si sta:
