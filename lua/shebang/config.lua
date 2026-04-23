local Util = require('shebang.util')

---@class ShebangOpts
---Whether to automatically make the target file an executable.
--- ---
---Default: `false`
--- ---
---@field auto_make_executable? boolean
---Whether to add a `/usr/bin/env` by default.
--- ---
---Default: `false`
--- ---
---@field env? boolean
---If `auto_make_executable` is enabled, indicates what file mode will be used.
---
---The string is 3 characters long, all must be numbers.
---
---See https://www.geeksforgeeks.org/linux-unix/chmod-command-linux/ to understand
---how `chmod` works.
--- ---
---Default: `'755'`
---@field file_mode? string

---@class ShebangDefaultOpts: ShebangOpts
---@field auto_make_executable boolean
---@field env boolean
---@field file_mode string

---@class Shebang.Config
---@field config ShebangOpts
local M = {}

M.config = {}

---@return ShebangDefaultOpts defaults
function M.get_defaults()
  return { ---@type ShebangDefaultOpts
    auto_make_executable = false,
    env = false,
    file_mode = '755',
  }
end

---@param mode string
---@return string mode
function M.check_mode(mode)
  Util.validate({ mode = { mode, { 'string' } } })

  if mode:len() ~= 3 then
    mode = M.get_defaults().file_mode
  end

  for _, c in ipairs(vim.split(mode, '', { trimempty = true })) do
    local ok, num = pcall(tonumber, c, 10) ---@type boolean, integer?
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

  M.config = vim.tbl_deep_extend('keep', opts, M.get_defaults())
  M.config.file_mode = M.check_mode(M.config.file_mode or M.get_defaults().file_mode)

  vim.g.shebang_setup = 1
end

return M
-- vim: set ts=2 sts=2 sw=2 et ai si sta:
