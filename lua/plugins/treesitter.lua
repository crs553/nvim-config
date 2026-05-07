vim.pack.add({
	{
		src = "https://github.com/nvim-treesitter/nvim-treesitter",
		commit = "4916d6592ede8c07973490d9322f187e07dfefac",
	},
})

require("nvim-treesitter").setup({
	highlight = { enable = true },
	indent = { enable = true },
	ensure_installed = {
		"bash",
		"c",
		"cmake",
		"cpp",
		"css",
		"diff",
		"gitignore",
		"html",
		"java",
		"javascript",
		"json",
		"latex",
		"lua",
		"markdown",
		"markdown_inline",
		"matlab",
		"python",
		"query",
		"regex",
		"rust",
		"toml",
		"tsx",
		"typescript",
		"vim",
		"vimdoc",
		"yaml",
	},
})


