if vim.g.shebang_command_created == 1 then
  return
end

vim.g.shebang_command_created = 1

vim.api.nvim_create_user_command('Shebang', function(ctx)
  local env = require('shebang.config').get().env
  if ctx.bang then
    env = not env
  end

  local mode = nil --[[@as string|nil|?]]
  if ctx.fargs[1]:sub(1, 5) == 'mode=' then
    mode = vim.split(ctx.fargs[1], '=', { trimempty = true })[2]
    table.remove(ctx.fargs, 1)
  end

  require('shebang.core').write_shebang(vim.api.nvim_get_current_buf(), ctx.fargs, env, mode)
end, {
  bang = true,
  bar = true,
  complete = function(_, line) ---@param line string
    local items = {} ---@type string[]
    local args = vim.split(line, '%s+', { trimempty = false })
    if args[1]:sub(-1) == '!' and #args == 1 then
      items = {}
    elseif #args == 2 and args[2]:len() > 0 and vim.startswith('mode=', args[2]) then
      items = { 'mode=' }
    elseif #args == 2 or (#args == 3 and vim.startswith(args[2], 'mode=')) then
      for v in pairs(require('shebang.core').langs_dict) do
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
