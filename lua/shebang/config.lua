---@module 'shebang._meta'

local Util = require('shebang.util')

---@class Shebang.Config
local M = {}

---@return ShebangDefaultOpts defaults
function M.get_defaults()
  return { ---@type ShebangDefaultOpts
    auto_make_executable = false,
    env = false,
    file_mode = '755',
  }
end

local config = M.get_defaults() ---@type ShebangDefaultOpts

---@return ShebangDefaultOpts config
function M.get()
  return config
end

---@param mode string
---@return string mode
function M.check_mode(mode)
  Util.validate({ mode = { mode, { 'string' } } })

  if mode:len() ~= 3 then
    mode = M.get_defaults().file_mode
  end

  for _, c in ipairs(vim.split(mode, '', { trimempty = true })) do
    local ok, num = pcall(tonumber, c, 10) ---@type boolean, integer|nil|?
    if not (ok and num) or num < 0 or num > 7 then
      mode = M.get_defaults().file_mode
      break
    end
  end

  return mode
end

---@param opts? ShebangOpts
function M.setup(opts)
  Util.validate({ opts = { opts, { 'table', 'nil' }, true } })
  opts = opts or {}

  Util.validate({
    ['opts.env'] = { opts.env, { 'boolean', 'nil' }, true },
    ['opts.auto_make_executable'] = { opts.auto_make_executable, { 'boolean', 'nil' }, true },
    ['opts.file_mode'] = { opts.file_mode, { 'string', 'nil' }, true },
  })

  local defaults = M.get_defaults()
  config = vim.tbl_deep_extend('force', defaults, opts)
  config.file_mode = M.check_mode(config.file_mode or defaults.file_mode)

  vim.g.shebang_setup = 1
end

return M
-- vim: set ts=2 sts=2 sw=2 et ai si sta:
