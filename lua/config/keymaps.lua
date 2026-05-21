-- lua/config/keymaps.lua
local map = vim.keymap.set

map("n", "<M-j>", "<cmd>cnext<CR>", { desc = "Quickfix Next" })
map("n", "<M-k>", "<cmd>cprev<CR>", { desc = "Quickfix Prev" })

map("n", "<space><space>x", "<cmd>source %<CR>", { desc = "Source File" })
map("n", "<space>x", ":.lua<CR>", { desc = "Run Line" })
map({ "x", "o" }, "<space>x", ":lua<CR>", { desc = "Run Selection" })

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
map("n", "<leader>qb", close_all_buffers_except_current, { desc = "Close all other buffers" })

map("n", "<leader>qc", function()
	vim.fn.setqflist({})
	vim.cmd("cclose")
	vim.notify("Quickfix list cleared")
end, { desc = "Clear quickfix list" })

map("n", "<c-k>", ":wincmd k<CR>", { desc = "Move up in split", silent = true })
map("n", "<c-j>", ":wincmd j<CR>", { desc = "Move down in split ", silent = true })
map("n", "<c-h>", ":wincmd h<CR>", { desc = "Move left in split", silent = true })
map("n", "<c-l>", ":wincmd l<CR>", { desc = "Move right in split", silent = true })

map("n", "<leader>lh", "<cmd>nohlsearch<CR>", { desc = "Clear search highlights" })

-- COPY/PASTE KEYMAPS --
map("n", "<leader>Y", function()
	local view = vim.fn.winsaveview()
	vim.cmd('keepjumps keepmarks normal! ggVG"+y')
	vim.fn.winrestview(view)
end, {
	desc = "Yank entire buffer to system clipboard",
})
map("n", "<leader>y", '"+yy', { desc = "Yank line to system clipboard" })
map({ "x", "o" }, "<leader>y", '"+y', { desc = "Yank selection to system clipboard" })
map("n", "<leader>p", '"+p', { desc = "Paste from system clipboard" })
map({ "x", "o" }, "<leader>p", '"+P', { desc = "Paste from system clipboard, replace selection" })

-- VISUAL MODE - SELECTION MANIPULATION --
map({ "x", "o" }, "J", ":move '>+1<CR>gv=gv", { desc = "Move selection down" })
map({ "x", "o" }, "K", ":move '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Visual mode: indent/unindent selection and keep selection active
map({ "x", "o" }, "<Tab>", ">gv", { desc = "Indent selection" })
map({ "x", "o" }, "<S-Tab>", "<gv", { desc = "unindent selection" })

-- captilise
map("n", "<M-u>", "gUiww", { desc = "Capitalise the inner word" })
map("n", "<M-l>", "guiww", { desc = "Decapitalise the inner word" })

-- toggle commenting -- command needs implementing could use treesitter to aid
--map("n", "<leader>cc", ":CommentToggle<CR>", { desc = "Toggle comment" })
--map("x", "<leader>cc", ":'<,'>CommentToggle<CR>", { desc = "Toggle comment in selection" })

-- Change buffer using leader keys
map("n", "<leader>bn", ":bnext<CR>", { desc = "Next buffer" })
map("n", "<leader>bp", ":bprevious<CR>", { desc = "Previous buffer" })

-- when in terminal mode use esc to return to normal mode
-- TODO: fix conflict with lazygit
--map("t", "<C-q>", [[<C-\><C-n>]], { desc = "Exit terminal mode" })
