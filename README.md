# shebang.nvim

Add any shebang to the top of your script.

> [!WARNING]
> **_This plugin is under construction, but the basic functionality works as intended._**

---

## Table of Contents

- [Installation](#installation)
  - [`vim-plug`](#vim-plug)
  - [`lazy.nvim`](#lazynvim)
  - [`pckr.nvim`](#pckrnvim)
  - [`nvim-plug`](#nvim-plug)
  - [`paq-nvim`](#paq-nvim)
  - [`vim.pack`](#vimpack)
- [Configuration](#configuration)
- [Usage](#usage)

---

## Installation

Requirements:

- Neovim >= `v0.10`
- [`numToStr/Comment.nvim`](https://github.com/numToStr/Comment.nvim)

If you want to add instructions for your plugin manager of preference
please raise a [**_BLANK ISSUE_**](https://github.com/DrKJeff16/shebang.nvim/issues/new?template=BLANK_ISSUE).

Use any plugin manager of your choosing.

### `vim-plug`

```vim
Plug 'DrKJeff16/shebang.nvim'
Plug 'numToStr/Comment.nvim'
```

### `lazy.nvim`

```lua
{
  'DrKJeff16/shebang.nvim',
  dependencies = { 'numToStr/Comment.nvim' },
  opts = {},
}
```

If you wish to lazy-load this plugin:

```lua
{
  'DrKJeff16/shebang.nvim',
  cmd = { -- Lazy-load by commands
    'Shebang',
  },
  dependencies = { 'numToStr/Comment.nvim' },
  opts = {},
}
```

### `pckr.nvim`

```lua
require('pckr').add({
  {
    'DrKJeff16/shebang.nvim',
    requires = { 'numToStr/Comment.nvim' },
    config = function()
      require('shebang').setup()
    end,
  }
})
```

### `nvim-plug`

```lua
require('plug').add({
  {
    'DrKJeff16/shebang.nvim',
    depends = { 'numToStr/Comment.nvim' },
    config = function()
      require('shebang').setup()
    end,
  },
})
```

### `paq-nvim`

```lua
local paq = require('paq')
paq({
  'DrKJeff16/shebang.nvim',
  'numToStr/Comment.nvim',
})
```

### `vim.pack`

```lua
vim.pack.add({
  { src = 'https://github.com/DrKJeff16/shebang.nvim', name = 'shebang.nvim' },
})
```

<!--

### LuaRocks

The package can be found [in the LuaRocks webpage](https://luarocks.org/modules/drkjeff16/shebang.nvim).

```bash
luarocks install shebang.nvim # Global install
luarocks install --local shebang.nvim # Local install
```

-->

---

## Configuration

```lua
require('shebang').setup({
  -- If enabled, `#!/usr/bin/env` will be used as a prefix by default
  env = false,
})
```

---

## Usage

You can use the `:Shebang` command:

```vim
:Shebang bash " Will add `#!/usr/bin/bash` or `#!/usr/bin/env bash`, depending on whether `env` is enabled or not
:Shebang lua " Will add `#!/usr/bin/lua` or `#!/usr/bin/env lua`, depending on whether `env` is enabled or not
```

If you have `env` set to `true`, adding a bang `!` to the command will invert that variable for
that command. For example:

```vim
" If `env` is `false`, the command will add `#!/usr/bin/env bash`.
" Otherwise, `#!/usr/bin/bash` will be added
:Shebang! bash
```

---

## License

[GPLv2](https://github.com/DrKJeff16/shebang.nvim/blob/main/LICENSE)

<!-- vim: set ts=2 sts=2 sw=2 et ai si sta: -->
