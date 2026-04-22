local ERROR = vim.log.levels.ERROR
local Util = require('shebang.util')
local Config = require('shebang.config')

local langs_dict = {
  bash = 'sh',
  csh = 'csh',
  fish = 'fish',
  lua = 'lua',
  luajit = 'lua',
  node = 'javascript',
  perl = 'perl',
  python = 'python',
  python3 = 'python3',
  ruby = 'ruby',
  sh = 'sh',
  tclsh = 'tcl',
  zsh = 'zsh',
}

---@class Shebang.Core
local M = {}

---@param bufnr integer
---@param prog string
---@param ft string
---@param lines string[]
function M.shebang_lines_write(bufnr, prog, ft, lines)
  Util.validate({
    bufnr = { bufnr, { 'number' } },
    prog = { prog, { 'string' } },
    ft = { ft, { 'string' } },
    lines = { lines, { 'table' } },
  })
  bufnr = Util.is_int(bufnr, bufnr >= 0) and bufnr or 0

  vim.api.nvim_set_option_value('filetype', ft, { buf = bufnr })
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, true, lines)
end

---@param prog string
---@param env? boolean
---@return string|nil shebang
function M.gen_shebang(prog, env)
  Util.validate({
    prog = { prog, { 'string' } },
    env = { env, { 'boolean', 'nil' }, true },
  })
  if env == nil then
    env = Config.config.env ~= nil and Config.config.env or Config.get_defaults().env --[[@as boolean]]
  end

  if env then
    return ('#!%s %s'):format(Util.exe_path('env'), prog)
  end
  return ('#!%s'):format(Util.exe_path(prog))
end

---@param bufnr integer
---@param prog string[]
---@param env? boolean
function M.write_shebang(bufnr, prog, env)
  Util.validate({
    bufnr = { bufnr, { 'number' } },
    prog = { prog, { 'table' } },
    env = { env, { 'boolean', 'nil' }, true },
  })
  bufnr = Util.is_int(bufnr, bufnr >= 0) and bufnr or 0
  if env == nil then
    env = Config.config.env ~= nil and Config.config.env or Config.get_defaults().env --[[@as boolean]]
  end

  local ft = nil ---@type string|nil
  for _, pos in ipairs(prog) do
    if vim.list_contains(vim.tbl_keys(langs_dict), pos) then
      ft = langs_dict[pos]
      break
    end
  end

  if not ft then
    vim.notify('(shebang.nvim): Unavailable filetype!', ERROR)
    return
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

  local shebang = M.gen_shebang(table.concat(prog, ' '), env)
  if not shebang then
    vim.notify('(shebang.nvim): Unable to generate shebang!', ERROR)
    return
  end

  local win = vim.api.nvim_get_current_win()
  local pos = vim.deepcopy(vim.api.nvim_win_get_cursor(win))
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, true)
  if lines[1]:find('^%#%!.*$') then
    lines[1] = shebang
  else
    table.insert(lines, 1, shebang)
    pos[1] = pos[1] + 1
  end

  pcall(vim.cmd.undojoin)
  pcall(vim.cmd.write, { bang = true })
  M.shebang_lines_write(bufnr, table.concat(prog, ' '), ft, lines)
  pcall(vim.cmd.write, { bang = true })

  vim.api.nvim_win_set_cursor(win, pos)
end

return M
-- vim: set ts=2 sts=2 sw=2 et ai si sta:
