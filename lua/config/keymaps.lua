-- lua/config/keymaps.lua
local map = vim.keymap.set

map("n", "<M-j>", "<cmd>cnext<CR>", { desc = "Quickfix Next" })
map("n", "<M-k>", "<cmd>cprev<CR>", { desc = "Quickfix Prev" })

map("n", "<space><space>x", "<cmd>source %<CR>", { desc = "Source File" })
map("n", "<space>x", ":.lua<CR>", { desc = "Run Line" })
map("v", "<space>x", ":lua<CR>", { desc = "Run Selection" })

