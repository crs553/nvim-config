vim.pack.add({ { src = "https://github.com/catppuccin/nvim", name = "catppuccin" } })

require("catppuccin").setup({
	flavour = "mocha",
	transparent_background = false,
	styles = {
		comments = { "italic" },
		conditionals = { "italic" },
	},
	integrations = {
		treesitter = true,
		native_lsp = { enabled = true },
		telescope = true,
		which_key = true,
		cmp = true,
		lualine = true,
		gitsigns = true,
		dap = { enabled = true },
		oil = true,
		markdown = true,
		mini = { enabled = true },
		snacks = { enabled = true },
	},

	custom_highlights = function(colors)
		return {
			LineNr = { fg = colors.overlay1 },
			CursorLineNr = { fg = colors.pink, style = { "bold" } },
			CursorLine = { bg = colors.surface0 },
		}
	end,
})
vim.cmd([[colorscheme catppuccin-mocha]])
