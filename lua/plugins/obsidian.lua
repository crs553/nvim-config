vim.pack.add({
	{ src = "https://github.com/obsidian-nvim/obsidian.nvim", version = "v3.16.3" },
	"nvim-lua/plenary.nvim",
})

local ok, local_config = pcall(require, "config.local")

local vaults = ok and local_config.obsidian or {}

require("obsidian").setup({
	workspaces = {
		{ name = "notes", path = vaults.notes },
	},
})

local map = vim.keymap.set

--map("n",
