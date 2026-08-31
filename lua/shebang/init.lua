---@class Shebang
---@field config Shebang.Config
---@field core Shebang.Core
---@field health Shebang.Health
---@field util Shebang.Util
local M = {}

---@param opts? ShebangOpts
function M.setup(opts)
  require('shebang.util').validate({ opts = { opts, { 'table', 'nil' }, true } })

  require('shebang.config').setup(opts or {})
  if vim.g.shebang_setup == 1 then
    vim.api.nvim_create_user_command('Shebang', function(ctx)
      local env = require('shebang.config').get().env
      if ctx.bang then
        env = not env
      end

      local mode = nil --[[@as string|nil]]
      if ctx.fargs[1]:sub(1, 5) == 'mode=' then
        mode = vim.split(ctx.fargs[1], '=', { trimempty = true })[2]
        table.remove(ctx.fargs, 1)
      end

      require('shebang.core').write_shebang(vim.api.nvim_get_current_buf(), ctx.fargs, env, mode)
    end, {
      bang = true,
      bar = true,
      ---@param line string
      ---@return string[] items
      complete = function(_, line)
        local items = {} ---@type string[]
        local args = vim.split(line, '%s+', { trimempty = false })
        if args[1]:sub(-1) == '!' and #args == 1 then
          items = {}
        elseif #args == 2 and args[2]:len() > 0 and vim.startswith('mode=', args[2]) then
          items = { 'mode=' }
        elseif #args == 2 or (#args == 3 and vim.startswith(args[2], 'mode=')) then
          for _, v in ipairs(vim.tbl_keys(require('shebang.core').langs_dict)) do
            ---@cast v string
            if vim.startswith(v, args[#args]) and not vim.list_contains(items, v) then
              table.insert(items, v)
            end
          end
        end

        table.sort(items)
        return items
      end,
      desc = 'Create a shebang on top of the current file',
      nargs = '+',
    })
  end
end

local Shebang = setmetatable(M, { ---@type Shebang
  __index = function(self, k)
    local raw = rawget(self, k) or nil
    if raw then
      return raw
    end

    if require('shebang.util').mod_exists('shebang.' .. k) then
      return require('shebang.util').rawset(self, k, require('shebang.' .. k))
    end
  end,
})

return Shebang
-- vim: set ts=2 sts=2 sw=2 et ai si sta:
