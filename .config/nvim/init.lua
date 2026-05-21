-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
require("config.options")
require("config.keymaps")
require("config.autocmds")

vim.opt.clipboard = "unnamedplus"

require("oil").setup()

-- vim.g.my_color_scheme = "backpack"
-- vim.cmd("colorscheme " .. vim.g.my_color_scheme)
