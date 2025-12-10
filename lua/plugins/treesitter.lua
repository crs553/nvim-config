return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate", -- Always keep parsers up to date

	event = { "BufReadPost", "BufNewFile" },

	opts = {
		highlight = { enable = true },
		indent = { enable = true },
		ensure_installed = {
			-- "all" installs everything, but it's heavy; better to specify
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
			"matlab", -- not in default set, so we add it
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
	},

	config = function(_, opts)
		require("nvim-treesitter.configs").setup(opts)
	end,
}
