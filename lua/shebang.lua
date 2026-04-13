local Util = require('shebang.util')

---@class Shebang
local M = {}

---@param opts? ShebangOpts
function M.setup(opts)
  Util.validate({ opts = { opts, { 'table', 'nil' }, true } })

  local Config = require('shebang.config')
  Config.setup(opts or {})

  if vim.g.shebang_setup ~= 1 then
    return
  end

  vim.api.nvim_create_user_command('Shebang', function(ctx)
    local env = Config.config.env --[[@as boolean]]
    if ctx.bang then
      env = not env
    end

    require('shebang.core').write_shebang(vim.api.nvim_get_current_buf(), table.concat(ctx.fargs))
  end, { bang = true, nargs = '+', desc = 'Create a shebang on top of the current file' })
end

return M
-- vim: set ts=2 sts=2 sw=2 et ai si sta:
