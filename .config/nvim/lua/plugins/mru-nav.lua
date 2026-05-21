return {
  "mjacobs/mru-nav.nvim",
  -- Use local dev checkout when present, otherwise fetch from GitHub.
  dev = vim.fn.isdirectory(vim.fn.expand("~/dd/gh/mru-nav.nvim")) == 1,
  cmd = { "MruFile", "MruBuffer", "MruClearFiles" },
  keys = {
    {
      "<leader>mf",
      function()
        require("mru_nav").mru_files()
      end,
      desc = "MRU file picker",
    },
    {
      "<leader>mb",
      function()
        require("mru_nav").mru_buffers()
      end,
      desc = "MRU buffer picker",
    },
  },
  opts = {},
}
