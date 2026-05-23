-- Most filetypes are configured by LazyVim + formatting.* extras (prettier, black).
-- Only shell formatting needs to be added here.
return {
  "stevearc/conform.nvim",
  opts = {
    formatters_by_ft = {
      sh = { "shfmt" },
      bash = { "shfmt" },
      zsh = { "shfmt" },
    },
  },
}
