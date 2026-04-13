local ERROR = vim.log.levels.ERROR
local Util = require('shebang.util')
local Config = require('shebang.config')

---@class Shebang.Core
local M = {}

---@param bufnr integer
---@param lines string[]
function M.shebang_lines_write(bufnr, lines)
  Util.validate({
    bufnr = { bufnr, { 'number' } },
    lines = { lines, { 'table' } },
  })
  bufnr = Util.is_int(bufnr, bufnr >= 0) and bufnr or 0

  vim.g.shebang_count = 0

  local win = vim.api.nvim_get_current_win()
  local do_shebang = vim.schedule_wrap(function()
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, true, lines)
    vim.g.shebang_count = vim.g.shebang_count + 1
    vim.cmd.write()
    vim.g.shebang_count = vim.g.shebang_count + 1
    vim.cmd.edit()
    vim.g.shebang_count = vim.g.shebang_count + 1
  end)
  local comment = vim.schedule_wrap(function()
    vim.api.nvim_win_set_cursor(win, { 1, 0 })
    vim.api.nvim_feedkeys(
      require('Comment.api').call('toggle.linewise.current', 'g@$')(),
      'n',
      false
    )
    vim.g.shebang_count = vim.g.shebang_count + 1
  end)

  local old_pos = vim.api.nvim_win_get_cursor(win)

  do_shebang()
  comment()
  vim.api.nvim_win_set_cursor(win, old_pos)
end

---@param prog string
---@param env? boolean
---@return string shebang
function M.gen_shebang(prog, env)
  Util.validate({
    prog = { prog, { 'string' } },
    env = { env, { 'boolean', 'nil' }, true },
  })
  if env == nil then
    env = Config.config.env ~= nil and Config.config.env or Config.get_defaults().env --[[@as boolean]]
  end
  if not Util.executable(prog) then
    error(('Executable not found: `%s`'):format(prog), ERROR)
  end

  if env then
    return ('#!%s %s'):format(Util.exe_path('env'), prog)
  end
  return ('#!%s'):format(Util.exe_path(prog))
end

---@param bufnr integer
---@param prog string
---@param env? boolean
function M.write_shebang(bufnr, prog, env)
  Util.validate({
    bufnr = { bufnr, { 'number' } },
    prog = { prog, { 'string' } },
    env = { env, { 'boolean', 'nil' }, true },
  })
  bufnr = Util.is_int(bufnr, bufnr >= 0) and bufnr or 0
  if env == nil then
    env = Config.config.env ~= nil and Config.config.env or Config.get_defaults().env --[[@as boolean]]
  end

  if not Util.mod_exists('Comment.api') then
    vim.notify('(shebang.nvim): `Comment.nvim` is not installed!', ERROR)
    return
  end
  if not Util.optget('modifiable', 'buf', bufnr) then
    vim.notify('(shebang.nvim): Current buffer is not modifiable!', ERROR)
    return
  end

  local bt = Util.optget('buftype', 'buf', bufnr) --[[@as string]]
  if not vim.list_contains({ '', 'acwrite' }, bt) then
    vim.notify(("(shebang.nvim): Current buffer's buftype is not valid! (`%s`)"):format(bt), ERROR)
    return
  end

  local shebang = M.gen_shebang(prog, env)
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, true)
  table.insert(lines, 1, shebang)

  vim.cmd.undojoin()
  M.shebang_lines_write(bufnr, lines)
end

return M
-- vim: set ts=2 sts=2 sw=2 et ai si sta:
