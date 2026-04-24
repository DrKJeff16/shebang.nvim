local Util = require('shebang.util')

---@param ctx vim.api.keyset.create_user_command.command_args
local function callback(ctx)
  local env = require('shebang.config').config.env --[[@as boolean]]
  if ctx.bang then
    env = not env
  end

  local mode = nil --[[@as string|nil]]
  if ctx.fargs[1]:sub(1, 5) == 'mode=' then
    mode = vim.split(ctx.fargs[1], '=', { trimempty = true })[2]
    table.remove(ctx.fargs, 1)
  end

  require('shebang.core').write_shebang(vim.api.nvim_get_current_buf(), ctx.fargs, env, mode)
end

---@param line string
---@return string[] items
local function completor(_, line)
  local args = vim.split(line, '%s+', { trimempty = false })
  if args[1]:sub(-1) == '!' and #args == 1 then
    return {}
  end

  if #args == 2 and args[2]:len() > 0 and vim.startswith('mode=', args[2]) then
    return { 'mode=' }
  end
  if #args == 2 or (#args == 3 and vim.startswith(args[2], 'mode=')) then
    local items, keys = {}, vim.tbl_keys(require('shebang.core').langs_dict) ---@type string[], string[]
    for _, v in ipairs(keys) do
      if vim.startswith(v, args[#args]) and not vim.list_contains(items, v) then
        table.insert(items, v)
      end
    end

    table.sort(items)
    return items
  end

  return {}
end

---@class Shebang
local M = {}

---@param opts? ShebangOpts
function M.setup(opts)
  Util.validate({ opts = { opts, { 'table', 'nil' }, true } })

  require('shebang.config').setup(opts or {})
  if vim.g.shebang_setup ~= 1 then
    return
  end

  vim.api.nvim_create_user_command('Shebang', callback, {
    bang = true,
    nargs = '+',
    complete = completor,
    desc = 'Create a shebang on top of the current file',
  })
end

return M
-- vim: set ts=2 sts=2 sw=2 et ai si sta:
