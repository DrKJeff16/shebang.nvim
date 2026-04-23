---Non-legacy validation spec (>=v0.11)
---@class ValidateSpec
---@field [1] any
---@field [2] vim.validate.Validator
---@field [3]? boolean
---@field [4]? string

local ERROR = vim.log.levels.ERROR
local MODSTR = 'shebang.util'

---@class Shebang.Util
local M = {}

---@param nums number[]|number
---@param cond? boolean
---@return boolean int
---@nodiscard
function M.is_int(nums, cond)
  M.validate({
    nums = { nums, { 'number', 'table' } },
    cond = { cond, { 'boolean', 'nil' }, true },
  })
  if cond == nil then
    cond = true
  end

  if M.is_type('number', nums) then
    ---@cast nums number
    return nums == math.floor(nums) and nums == math.ceil(nums) and cond
  end

  ---@cast nums number[]
  for _, num in ipairs(nums) do
    if not M.is_int(num) then
      return false
    end
  end

  return cond
end

---@overload fun(option: string|vim.wo|vim.bo): value: any
---@overload fun(option: string|vim.wo|vim.bo, param: 'scope', param_value: 'local'|'global'): value: any
---@overload fun(option: string|vim.wo|vim.bo, param: 'ft', param_value: string): value: any
---@overload fun(option: string|vim.wo|vim.bo, param: 'buf'|'win', param_value: integer): value: any
function M.optget(option, param, param_value)
  M.validate({
    option = { option, { 'string' } },
    param = { param, { 'string', 'nil' }, true },
    param_value = { param_value, { 'string', 'number', 'nil' }, true },
  })
  param = param or 'buf'
  if not vim.list_contains({ 'scope', 'ft', 'buf', 'win' }, param) then
    error(
      ('Bad parameter: `%s`\nCan only accept `scope`, `ft`, `buf` or `win`!'):format(
        vim.inspect(param)
      ),
      ERROR
    )
  end
  if param == 'scope' then
    param_value = param_value or 'local'
    if not vim.list_contains({ 'global', 'local' }, param_value) then
      error(
        ('Bad param value `%s`\nCan only accept `global` or `local`!'):format(
          vim.inspect(param_value)
        ),
        ERROR
      )
    end
  end
  if param == 'ft' and (not param_value or type(param_value) ~= 'string') then
    error('Missing/bad value for `ft` parameter!', ERROR)
  end
  if vim.list_contains({ 'win', 'buf' }, param) then
    if
      not (
        param_value
        and type(param_value) == 'number'
        and M.is_int(param_value, param_value >= 0)
      )
    then
      error('Missing/bad value for `win`/`buf` parameter!', ERROR)
    end
  end

  return vim.api.nvim_get_option_value(option, { [param] = param_value })
end

---@overload fun(option: string|vim.wo|vim.bo, value: any)
---@overload fun(option: string|vim.wo|vim.bo, value: any, param: 'scope', param_value: 'local'|'global')
---@overload fun(option: string|vim.wo|vim.bo, value: any, param: 'ft', param_value: string)
---@overload fun(option: string|vim.wo|vim.bo, value: any, param: 'buf'|'win', param_value: integer)
function M.optset(option, value, param, param_value)
  M.validate({
    option = { option, { 'string' } },
    param = { param, { 'string', 'nil' }, true },
    param_value = { param_value, { 'string', 'number', 'nil' }, true },
  })
  if value == nil then
    error('Empty option value is unacceptable!', ERROR)
  end
  param = param or 'buf'
  if not vim.list_contains({ 'scope', 'ft', 'buf', 'win' }, param) then
    error(
      ('Bad parameter: `%s`\nCan only accept `scope`, `ft`, `buf` or `win`!'):format(
        vim.inspect(param)
      ),
      ERROR
    )
  end
  if param == 'scope' then
    param_value = param_value or 'local'
    if not vim.list_contains({ 'global', 'local' }, param_value) then
      error(
        ('Bad param value `%s`\nCan only accept `global` or `local`!'):format(
          vim.inspect(param_value)
        ),
        ERROR
      )
    end
  end
  if param == 'ft' and (not param_value or type(param_value) ~= 'string') then
    error('Missing/bad value for `ft` parameter!', ERROR)
  end
  if vim.list_contains({ 'win', 'buf' }, param) then
    if
      not (
        param_value
        and type(param_value) == 'number'
        and M.is_int(param_value, param_value >= 0)
      )
    then
      error('Missing/bad value for `win`/`buf` parameter!', ERROR)
    end
  end

  vim.api.nvim_set_option_value(option, value, { [param] = param_value })
end

---@param list string[]
---@return string[] trimmed_list
function M.trimempty(list)
  M.validate({ list = { list, { 'table' } } })
  if not vim.islist(list) then
    error('Parameter table is not list-like!', ERROR)
  end
  if vim.tbl_isempty(list) then
    return list
  end

  local trimmed_list = {} ---@type string[]
  for _, v in ipairs(list) do
    if v ~= '' then
      table.insert(trimmed_list, v)
    end
  end
  return trimmed_list
end

---Checks whether nvim is running on Windows.
--- ---
---@return boolean win32
function M.is_windows()
  return M.vim_has('win32')
end

---Get rid of all duplicates in the given list.
---
---If the list is empty it'll just return it as-is.
---
---If the data passed to the function is not a table,
---an error will be raised.
--- ---
---@param T any[]
---@return any[] NT
function M.dedup(T)
  M.validate({ T = { T, { 'table' } } })
  if vim.tbl_isempty(T) or not vim.islist(T) then
    return T
  end

  local NT = {} ---@type any[]
  for _, v in ipairs(T) do
    local not_dup = false
    if M.is_type('table', v) then
      not_dup = not vim.tbl_contains(NT, function(val)
        return vim.deep_equal(val, v)
      end, { predicate = true })
    else
      not_dup = not vim.list_contains(NT, v)
    end
    if not_dup then
      table.insert(NT, v)
    end
  end
  return NT
end

---@param feature string
---@return boolean has
function M.vim_has(feature)
  return vim.fn.has(feature) == 1
end

---Dynamic `vim.validate()` wrapper which covers both legacy and newer implementations.
--- ---
---@param T table<string, vim.validate.Spec|ValidateSpec>
function M.validate(T)
  local max = vim.fn.has('nvim-0.11') == 1 and 3 or 4
  for name, spec in pairs(T) do
    while #spec > max do
      table.remove(spec, #spec)
    end
    T[name] = spec
  end

  if vim.fn.has('nvim-0.11') ~= 1 then
    vim.validate(T)
    return
  end

  for name, spec in pairs(T) do
    table.insert(spec, 1, name)
    vim.validate(unpack(spec))
  end
end

---@param T table<string|integer, any>
---@return integer len
function M.get_dict_size(T)
  M.validate({ T = { T, { 'table' } } })

  if vim.tbl_isempty(T) then
    return 0
  end

  local len = 0
  for _, _ in pairs(T) do
    len = len + 1
  end
  return len
end

---Reverses a given list-like table.
---
---If the passed data is an empty table it'll be returned as-is.
---
---If the data passed to the function is not a table,
---an error will be raised.
--- ---
---@param T any[]
---@return any[] T
function M.reverse(T)
  M.validate({ T = { T, { 'table' } } })

  if vim.tbl_isempty(T) then
    return T
  end

  local len = #T
  for i = 1, math.floor(len / 2) do
    T[i], T[len - i + 1] = T[len - i + 1], T[i]
  end
  return T
end

---Checks if module `mod` exists to be imported.
--- ---
---@param mod string The `require()` argument to be checked
---@param ret? boolean Whether to return the called module
---@return boolean exists A boolean indicating whether the module exists or not
---@return unknown? module
---@overload fun(mod: string): exists: boolean
function M.mod_exists(mod, ret)
  M.validate({
    mod = { mod, { 'string' } },
    ret = { ret, { 'boolean', 'nil' }, true },
  })
  ret = ret ~= nil and ret or false

  if mod == '' then
    return false
  end
  local exists, module = pcall(require, mod)

  if ret then
    return exists, module
  end

  return exists
end

---Checks whether `data` is of type `t` or not.
---
---If `data` is `nil`, the function will always return `false`.
--- ---
---@param t type Any return value the `type()` function would return
---@param data any The data to be type-checked
---@return boolean correct_type
function M.is_type(t, data)
  return data ~= nil and type(data) == t
end

---@param exe string[]|string
---@return boolean is_executable
function M.executable(exe)
  M.validate({ exe = { exe, { 'string', 'table' } } })

  ---@cast exe string
  if M.is_type('string', exe) then
    return vim.fn.executable(exe) == 1
  end

  local res = false

  ---@cast exe string[]
  for _, v in ipairs(exe) do
    res = M.executable(v)
    if not res then
      break
    end
  end
  return res
end

---Left strip given a leading string (or list of strings) within a string, if any.
--- ---
---@param char string[]|string
---@param str string
---@return string new_str
function M.lstrip(char, str)
  M.validate({
    char = { char, { 'string', 'table' } },
    str = { str, { 'string' } },
  })

  if str == '' or not vim.startswith(str, char) then
    return str
  end

  ---@cast char string[]
  if M.is_type('table', char) then
    if not vim.tbl_isempty(char) then
      for _, c in ipairs(char) do
        str = M.lstrip(c, str)
      end
    end
    return str
  end

  ---@cast char string
  local i, len, new_str = 1, str:len(), ''
  local other = false
  while i <= len + 1 do
    if str:sub(i, i) ~= char and not other then
      other = true
    end
    if other then
      new_str = ('%s%s'):format(new_str, str:sub(i, i))
    end
    i = i + 1
  end
  return new_str
end

---Right strip given a leading string (or list of strings) within a string, if any.
--- ---
---@param char string[]|string
---@param str string
---@return string new_str
function M.rstrip(char, str)
  M.validate({
    char = { char, { 'string', 'table' } },
    str = { str, { 'string' } },
  })

  if str == '' then
    return str
  end

  ---@cast char string[]
  if M.is_type('table', char) then
    if not vim.tbl_isempty(char) then
      for _, c in ipairs(char) do
        str = M.rstrip(c, str)
      end
    end
    return str
  end

  ---@cast char string
  str = str:reverse()

  if not vim.startswith(str, char) then
    return str:reverse()
  end
  return M.lstrip(char, str):reverse()
end

---Strip given a leading string (or list of strings) within a string, if any, bidirectionally.
--- ---
---@param char string[]|string
---@param str string
---@return string new_str
function M.strip(char, str)
  M.validate({
    char = { char, { 'string', 'table' } },
    str = { str, { 'string' } },
  })

  if str == '' then
    return str
  end

  ---@cast char string[]
  if M.is_type('table', char) then
    if not vim.tbl_isempty(char) then
      for _, c in ipairs(char) do
        str = M.strip(c, str)
      end
    end
    return str
  end

  ---@cast char string
  return M.rstrip(char, M.lstrip(char, str))
end

---@param exe string
---@return string path
function M.exe_path(exe)
  M.validate({ exe = { exe, { 'string' } } })

  local split = M.trimempty(
    vim.split(
      vim.api.nvim_exec2(
        ('!%s %s'):format(M.executable('which') and 'which' or 'command -v', exe),
        { output = true }
      ).output,
      '\n',
      { trimempty = true }
    )
  )
  return split[#split]
end

return M
-- vim: set ts=2 sts=2 sw=2 et ai si sta:
