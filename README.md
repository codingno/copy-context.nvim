# copy-context.nvim

Copy the current visual selection as file context for AI chat tools.

The default output is markdown with the file path, selected line range, and selected code:

````markdown
`lua/example.lua:12-20`

```lua
selected code here
```
````

## Installation

With [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
return {
  "codingno/copy-context.nvim",
  opts = {
    path_style = "relative",
    include_content = true,
  },
  keys = {
    {
      "<C-l>",
      function()
        require("copy-context").copy_visual()
      end,
      mode = "v",
      desc = "Copy selected code context",
    },
    {
      "<D-l>",
      function()
        require("copy-context").copy_visual()
      end,
      mode = "v",
      desc = "Copy selected code context",
    },
  },
}
```

`<C-l>` works in terminal Neovim on Linux, Windows, and macOS.

`<D-l>` is intended for macOS GUI Neovim clients. Terminal Neovim usually cannot receive Cmd key mappings because terminals intercept them.

## Configuration

Defaults:

```lua
require("copy-context").setup({
  path_style = "relative", -- "relative", "absolute", or "filename"
  include_content = true,
  clipboard_register = "+",
  notify = true,
  format = "markdown", -- "markdown", "plain", or a custom function
})
```

Plain output:

```lua
require("copy-context").setup({
  format = "plain",
})
```

Reference-only output:

```lua
require("copy-context").setup({
  include_content = false,
})
```

Custom formatter:

```lua
require("copy-context").setup({
  format = function(ctx)
    return string.format("@%s:%d-%d\n%s", ctx.path, ctx.start_line, ctx.end_line, table.concat(ctx.content, "\n"))
  end,
})
```

Formatter context:

```lua
{
  path = "lua/example.lua",
  absolute_path = "/Users/me/project/lua/example.lua",
  filename = "example.lua",
  start_line = 12,
  end_line = 20,
  content = { "selected code here" },
  filetype = "lua",
}
```

## Usage

1. Select code in visual mode.
2. Press `<C-l>`.
3. Paste into your chat or AI tool.

The plugin copies whole selected lines. This keeps context readable and stable for chat workflows.
