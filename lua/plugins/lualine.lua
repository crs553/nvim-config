vim.pack.add({
	"https://github.com/nvim-lualine/lualine.nvim",
	"https://github.com/nvim-tree/nvim-web-devicons", -- optional, for icons
})

-- Lualine setup
require("lualine").setup({
	options = {
		theme = "auto",
		section_separators = { left = "", right = "" },
		component_separators = { left = "", right = "" },
		globalstatus = true, -- requires Neovim 0.8+
	},
	sections = {
		lualine_a = { "mode" },
		lualine_b = { "branch", "diff", "diagnostics" },
		lualine_c = { "filename" },
		lualine_x = { "encoding", "fileformat", "filetype" },
		lualine_y = { "progress" },
		lualine_z = { "location" },
	},
})
