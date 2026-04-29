# copy-context.nvim

Copy the current visual selection as file context for Opencode and other AI chat tools.

The default output uses an absolute file path, selected line range, and selected code:

```text
/Users/codingno/project/lua/example.lua:12-20

selected code here
```

## Installation

With [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
return {
  "codingno/copy-context.nvim",
  opts = {
    path_style = "absolute",
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
  path_style = "absolute", -- "absolute", "relative", or "filename"
  include_content = true,
  clipboard_register = "+",
  notify = true,
  format = "context", -- "context", "markdown", "plain", or a custom function
})
```

Markdown output:

```lua
require("copy-context").setup({
  format = "markdown",
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
    return string.format("%s:%d-%d\n\n%s", ctx.path, ctx.start_line, ctx.end_line, table.concat(ctx.content, "\n"))
  end,
})
```

Formatter context:

```lua
{
  path = "/Users/me/project/lua/example.lua",
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
3. Paste into Opencode.
4. Add your instruction after the pasted context.

The plugin copies whole selected lines. This keeps context readable and stable for chat workflows.

Example Opencode prompt:

```text
/Users/codingno/personal/nvim/copy-context.nvim/lua/copy-context/init.lua:13-17

local function notify(message, level)
  if M.config.notify then
    vim.notify(message, level or vim.log.levels.INFO, { title = "copy-context.nvim" })
  end
end

Please explain this function and suggest if the notification behavior should be configurable.
```

## Why This Format?

AI editors such as Antigravity, Cursor, and Codex-style extensions usually add context through their own internal editor APIs, not by using a public universal clipboard format. Opencode can still use pasted text well, so for a Neovim clipboard workflow the most portable format is:

```text
/absolute/path/to/file.ext:start-end

selected code
```

This gives the AI tool both the exact file identity and the selected content. Absolute paths are best when the chat tool runs on the same machine because the file can be resolved without guessing the workspace root.
