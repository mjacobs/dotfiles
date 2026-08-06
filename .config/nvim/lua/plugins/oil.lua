return {
  "stevearc/oil.nvim",
  ---@module 'oil'
  ---@type oil.SetupOpts
  opts = {
    sort = {
      -- sort order can be "asc" or "desc"
      -- see :help oil-columns to see which columns are sortable
      { "type", "asc" },
      { "name", "asc" },
    },
    -- Use trash instead of deleting permanently
    delete_to_trash = true,
    view_options = {
      -- Show hidden files by default (like dotfiles)
      show_hidden = true,
    },
  },
  keys = {
    -- Toggle floating file explorer
    { "<leader>-", "<cmd>Oil --float<cr>", desc = "Open parent directory in float" },
  },
  -- Optional dependencies
  dependencies = { { "nvim-mini/mini.icons", opts = {} } },
  -- dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if you prefer nvim-web-devicons
  -- Lazy loading is not recommended because it is very tricky to make it work correctly in all situations.
  lazy = false,
}
