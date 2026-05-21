return {
  {
    "mason-org/mason.nvim",
    opts = {},
  },
  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = {
      "neovim/nvim-lspconfig",
      "mason-org/mason.nvim",
    },
    opts = {
      ensure_installed = {
        -- Python
        "basedpyright",
        "ruff",
        -- Lua
        "lua_ls",
        -- Rust
        "rust_analyzer",
        -- Go
        "gopls",
        -- TypeScript/JavaScript
        "ts_ls",
        -- Shell
        "bashls",
      },
    },
  },
}
