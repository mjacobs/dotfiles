return {
  {
    "neovim/nvim-lspconfig",
  },
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
        "basedpyright",
        "ruff",
      },
    },
  },
}
-- return {
--   {
--     "mason-org/mason.nvim",
--     build = ":MasonUpdate",
--     config = function()
--       require("mason").setup({
--         ui = { check_outdated_packages_on_open = true },
--       })
--     end,
--   },
--   {
--     "mason-org/mason-lspconfig.nvim",
--     dependencies = { "mason-org/mason.nvim", "neovim/nvim-lspconfig" },
--     config = function()
--       require("mason-lspconfig").setup({
--         ensure_installed = { "rust_analyzer", "lua_ls", "pyright" },
--         automatic_installation = true,
--       })
--
--       require("mason-lspconfig").setup_handlers({
--         function(server)
--           require("lspconfig")[server].setup({})
--         end,
--         ["rust_analyzer"] = function()
--           require("lspconfig").rust_analyzer.setup({
--             cmd = { vim.fn.expand("~/.cargo/bin/rust-analyzer") },
--             settings = {
--               ["rust-analyzer"] = {
--                 cargo = { allFeatures = true },
--                 checkOnSave = { command = "clippy" },
--               },
--             },
--           })
--         end,
--       })
--     end,
--   },
-- }
