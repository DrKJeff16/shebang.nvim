local uv = vim.uv or vim.loop
local ERROR = vim.log.levels.ERROR
local MODSTR = 'shebang.core'
local Util = require('shebang.util')
local Config = require('shebang.config')

---@class Shebang.Core
---@field langs_dict table<string, string>
local M = {}

M.langs_dict = {
  bash = 'sh',
  csh = 'csh',
  fish = 'fish',
  julia = 'julia',
  lua = 'lua',
  luajit = 'lua',
  node = 'javascript',
  perl = 'perl',
  python = 'python',
  python3 = 'python3',
  ruby = 'ruby',
  sh = 'sh',
  tclsh = 'tcl',
  vim = 'vim',
  zsh = 'zsh',
}

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

---@param path string
---@param mode? string
function M.make_executable(path, mode)
  Util.validate({
    path = { path, { 'string' } },
    mode = { mode, { 'string', 'nil' }, true },
  })
  mode = Config.check_mode(mode or Config.config.file_mode)

  if not uv.fs_chmod(path, tonumber(mode, 8)) then
    vim.notify(('(%s.make_executable): Failed to make file executable!'):format(MODSTR), ERROR)
  end
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

  return '#!' .. (env and ('%s %s'):format(Util.exe_path('env'), prog) or ('%s'):format(Util.exe_path(prog)))
end

---@param bufnr integer
---@param prog string[]
---@param env? boolean
---@param mode? string
function M.write_shebang(bufnr, prog, env, mode)
  Util.validate({
    bufnr = { bufnr, { 'number' } },
    prog = { prog, { 'table' } },
    env = { env, { 'boolean', 'nil' }, true },
    mode = { mode, { 'string', 'nil' }, true },
  })
  bufnr = Util.is_int(bufnr, bufnr >= 0) and bufnr or 0
  if env == nil then
    env = Config.config.env
  end
  mode = mode or Config.config.file_mode

  local ft = nil ---@type string|nil
  for _, pos in ipairs(prog) do
    if vim.list_contains(vim.tbl_keys(M.langs_dict), pos) then
      ft = M.langs_dict[pos]
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

  M.shebang_lines_write(bufnr, table.concat(prog, ' '), ft, lines)
  pcall(vim.cmd.undojoin)

  vim.api.nvim_win_set_cursor(win, pos)

  if Config.config.auto_make_executable then
    local path = Util.rstrip('/', vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ':p'))
    if not (vim.fn.filereadable(path) == 1 and vim.fn.filewritable(path) == 1) then
      return
    end

    local ok = pcall(vim.cmd.write, { bang = true })
    if ok then
      M.make_executable(path, mode)
    end
  end
end

return M
-- vim: set ts=2 sts=2 sw=2 et ai si sta:
