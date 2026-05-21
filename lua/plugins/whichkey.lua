vim.pack.add({
	"https://github.com/folke/which-key.nvim",
	"https://github.com/nvim-mini/mini.icons",
})

local wk = require("which-key")
wk.setup({})

vim.keymap.set("n", "<leader>?", function()
	wk.show({ global = false })
end, { desc = "Buffer Local Keymaps (which-key)" })

-- add groups
wk.add({
	{ "<leader>a", group = "AI" },
	{ "<leader>ac", group = "CLI" },
	{ "<leader>b", group = "Buffers" },
	{ "<leader>d", group = "DAP" },
	{ "<leader>f", group = "Find..." },
	{ "<leader>fi", group = "Find In ..." },
	{ "<leader>g", group = "Git" },
	{ "<leader>l", group = "LSP" },
	{ "<leader>o", group = "Obsidian" },
	{ "<leader>q", group = "Quickfix" },
	{ "<leader>s", group = "Search In ..." },
	{ "<leader>u", group = "Undo ..." },
	{ "<leader>v", group = "Vim Pack ..." },
	{ "<leader><leader>", group = "Source..." },
})
