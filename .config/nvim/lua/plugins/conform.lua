local function markdown_prettier_args(_, ctx)
  local ft = vim.bo[ctx.buf].filetype
  if ft ~= "markdown" and ft ~= "markdown.mdx" then
    return {}
  end

  local width = vim.bo[ctx.buf].textwidth
  if width <= 0 then
    width = 80
  end

  return { "--prose-wrap", "always", "--print-width", tostring(width) }
end

local function selected_range()
  local mode = vim.api.nvim_get_mode().mode
  local start_pos = vim.fn.getpos("v")
  local end_pos = vim.fn.getpos(".")

  if start_pos[2] == 0 or end_pos[2] == 0 then
    start_pos = vim.fn.getpos("'<")
    end_pos = vim.fn.getpos("'>")
  end

  local start_line, start_col = start_pos[2], start_pos[3]
  local end_line, end_col = end_pos[2], end_pos[3]

  if start_line > end_line or (start_line == end_line and start_col > end_col) then
    start_line, end_line = end_line, start_line
    start_col, end_col = end_col, start_col
  end

  if mode == "V" or vim.fn.visualmode() == "V" then
    start_col = 1
    end_col = #vim.api.nvim_buf_get_lines(0, end_line - 1, end_line, false)[1] + 1
  end

  return {
    start = { start_line, math.max(start_col - 1, 0) },
    ["end"] = { end_line, end_col },
  }
end

local function native_gq(range)
  local view = vim.fn.winsaveview()
  local formatexpr = vim.bo.formatexpr
  local line_count = math.max(range["end"][1] - range.start[1], 0)

  vim.bo.formatexpr = ""
  vim.api.nvim_win_set_cursor(0, { range.start[1], range.start[2] })

  local ok
  if line_count == 0 then
    ok = pcall(vim.cmd, "silent! normal! gqq")
  else
    ok = pcall(vim.cmd, ("silent! normal! gq%dj"):format(line_count))
  end

  vim.bo.formatexpr = formatexpr
  vim.fn.winrestview(view)

  return ok
end

local function format_selection()
  local conform = require("conform")
  local range = selected_range()
  local formatters = conform.list_formatters_to_run(0)

  if #formatters == 0 then
    native_gq(range)
    return
  end

  conform.format({
    async = true,
    lsp_format = "fallback",
    range = range,
  })
end

-- Most filetypes are configured by LazyVim + formatting.* extras (prettier, black).
-- This file adds shell formatting plus a visual gq bridge for selected ranges.
return {
  "stevearc/conform.nvim",
  keys = {
    {
      "gq",
      format_selection,
      mode = "x",
      desc = "Format selection",
    },
  },
  opts = {
    formatters_by_ft = {
      sh = { "shfmt" },
      bash = { "shfmt" },
      zsh = { "shfmt" },
    },
    formatters = {
      prettier = {
        append_args = markdown_prettier_args,
      },
    },
  },
}
