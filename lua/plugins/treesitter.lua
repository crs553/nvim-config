vim.pack.add({
	{
		src = "https://github.com/nvim-treesitter/nvim-treesitter",
	},
})

vim.cmd([[silent! TSUpdate]])

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

vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
	callback = function()
		if not pcall(require, "nvim-treesitter.parsers") then
			vim.notify("nvim-treesitter no parsers!", vim.log.levels.WARN)
		end

		if vim.o.diff then -- except in diff mode
			return
		end

		local last_pos = vim.api.nvim_buf_get_mark(0, '"') -- {line, col}
		local last_line = vim.api.nvim_buf_line_count(0)

		local row = last_pos[1]
		if row < 1 or row > last_line then
			return
		end

		pcall(vim.api.nvim_win_set_cursor, 0, last_pos)
	end,
})
