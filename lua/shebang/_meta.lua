---@meta

---Non-legacy validation spec (>=v0.11)
---@class Shebang.ValidateSpec
---@field [1] any
---@field [2] vim.validate.Validator
---@field [3]? boolean
---@field [4]? string

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

-- vim: set ts=2 sts=2 sw=2 et ai si sta:
