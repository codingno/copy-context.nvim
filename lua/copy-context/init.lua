local M = {}

local defaults = {
  path_style = "absolute",
  include_content = true,
  clipboard_register = "+",
  notify = true,
  format = "context",
}

M.config = vim.deepcopy(defaults)

local function notify(message, level)
  if M.config.notify then
    vim.notify(message, level or vim.log.levels.INFO, { title = "copy-context.nvim" })
  end
end

local function normalize_range(start_line, end_line)
  if start_line <= end_line then
    return start_line, end_line
  end

  return end_line, start_line
end

local function get_path(bufnr)
  local absolute_path = vim.api.nvim_buf_get_name(bufnr)

  if absolute_path == "" then
    return "[No Name]", "[No Name]", "[No Name]"
  end

  local relative_path = vim.fn.fnamemodify(absolute_path, ":.")
  local filename = vim.fn.fnamemodify(absolute_path, ":t")

  if M.config.path_style == "absolute" then
    return absolute_path, absolute_path, filename
  end

  if M.config.path_style == "filename" then
    return filename, absolute_path, filename
  end

  return relative_path, absolute_path, filename
end

local function build_default_text(ctx)
  local range = string.format("%s:%d-%d", ctx.path, ctx.start_line, ctx.end_line)

  if not M.config.include_content then
    return range
  end

  local content = table.concat(ctx.content, "\n")

  if M.config.format == "context" or M.config.format == "plain" then
    return string.format("%s\n\n%s", range, content)
  end

  local filetype = ctx.filetype ~= "" and ctx.filetype or "text"

  return string.format("`%s`\n\n```%s\n%s\n```", range, filetype, content)
end

function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", vim.deepcopy(defaults), opts or {})
end

function M.copy_visual()
  local bufnr = 0
  local start_line = vim.fn.line("'<")
  local end_line = vim.fn.line("'>")

  if start_line == 0 or end_line == 0 then
    notify("No visual selection found", vim.log.levels.WARN)
    return
  end

  start_line, end_line = normalize_range(start_line, end_line)

  local path, absolute_path, filename = get_path(bufnr)
  local content = vim.api.nvim_buf_get_lines(bufnr, start_line - 1, end_line, false)
  local ctx = {
    path = path,
    absolute_path = absolute_path,
    filename = filename,
    start_line = start_line,
    end_line = end_line,
    content = content,
    filetype = vim.bo[bufnr].filetype,
  }

  local text
  if type(M.config.format) == "function" then
    text = M.config.format(ctx)
  else
    text = build_default_text(ctx)
  end

  vim.fn.setreg(M.config.clipboard_register, text)
  notify(string.format("Copied %s:%d-%d", path, start_line, end_line))
end

return M
