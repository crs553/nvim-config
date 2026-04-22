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
	vim.notify("Non-focused buffers deleted")
end
-- Map to a key (e.g., <leader>q)
map("n", "<leader>q", close_all_buffers_except_current, { desc = "Close all other buffers" })

map("n", "<c-k>", ":wincmd k<CR>", { desc = "Move up in split", silent = true })
map("n", "<c-j>", ":wincmd j<CR>", { desc = "Move down in split ", silent = true })
map("n", "<c-h>", ":wincmd h<CR>", { desc = "Move left in split", silent = true })
map("n", "<c-l>", ":wincmd l<CR>", { desc = "Move right in split", silent = true })

map("n", "<leader>sqf", function()
	local pattern = vim.fn.input("Search in file: ")
	if pattern == "" then
		return
	end
	vim.fn.setreg("/", pattern)
	vim.cmd("cexpr []")
	vim.cmd("vimgrep /" .. pattern .. "/ %")
	vim.cmd("copen")
end, { desc = "Search quickfix in current buffer" })

map("n", "<leader>sqb", function()
	local pattern = vim.fn.input("Search in buffers: ")
	if pattern == "" then
		return
	end
	vim.fn.setreg("/", pattern)
	vim.cmd("cexpr []")
	vim.cmd("vimgrep /" .. pattern .. "/gj ##")
	vim.cmd("copen")
end, { desc = "Search quickfix in all open buffers" })
