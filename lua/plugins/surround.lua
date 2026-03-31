vim.pack.add({
	{
		src = "https://github.com/kylechui/nvim-surround",
	},
})

-- Normal mode
vim.keymap.set("n", "ys", "<cmd>lua require('nvim-surround').normal()<CR>", { desc = "Surround: normal" })
vim.keymap.set("n", "yss", "<cmd>lua require('nvim-surround').normal_cur()<CR>", { desc = "Surround: normal current" })
vim.keymap.set("n", "yS", "<cmd>lua require('nvim-surround').normal_line()<CR>", { desc = "Surround: normal line" })
vim.keymap.set(
	"n",
	"ySS",
	"<cmd>lua require('nvim-surround').normal_cur_line()<CR>",
	{ desc = "Surround: normal current line" }
)

-- Visual mode
vim.keymap.set("v", "S", "<cmd>lua require('nvim-surround').visual()<CR>", { desc = "Surround: visual" })
vim.keymap.set("v", "gS", "<cmd>lua require('nvim-surround').visual_line()<CR>", { desc = "Surround: visual line" })

-- Operator mode
vim.keymap.set("n", "ds", "<cmd>lua require('nvim-surround').delete()<CR>", { desc = "Surround: delete" })
vim.keymap.set("n", "cs", "<cmd>lua require('nvim-surround').change()<CR>", { desc = "Surround: change" })
vim.keymap.set("n", "cS", "<cmd>lua require('nvim-surround').change_line()<CR>", { desc = "Surround: change line" })
