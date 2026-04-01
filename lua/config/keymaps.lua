-- lua/config/keymaps.lua
local map = vim.keymap.set

map("n", "<M-j>", "<cmd>cnext<CR>", { desc = "Quickfix Next" })
map("n", "<M-k>", "<cmd>cprev<CR>", { desc = "Quickfix Prev" })

map("n", "<space><space>x", "<cmd>source %<CR>", { desc = "Source File" })
map("n", "<space>x", ":.lua<CR>", { desc = "Run Line" })
map("v", "<space>x", ":lua<CR>", { desc = "Run Selection" })

local function close_all_buffers_except_current()
	local bufs = vim.api.nvim_list_bufs()
	local current_buf = vim.api.nvim_get_current_buf()
	for _, buf in ipairs(bufs) do
		if buf ~= current_buf then
			vim.api.nvim_buf_delete(buf, { force = true })
		end
	end
end
-- Map to a key (e.g., <leader>q)
vim.keymap.set("n", "<leader>q", close_all_buffers_except_current, { desc = "Close all other buffers" })
