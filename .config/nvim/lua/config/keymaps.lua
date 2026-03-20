-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Use q to open buffer list instead of macro recording
vim.keymap.set("n", "q", function()
  Snacks.picker.buffers()
end, { desc = "Buffer list" })
