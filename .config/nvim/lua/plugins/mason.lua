-- LSP servers themselves are installed by the lang.* extras.
-- This file only ensures CLI tools used by conform/none-ls that aren't
-- covered by an extra (shfmt for sh/bash/zsh formatting).
return {
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "shfmt" })
    end,
  },
}
