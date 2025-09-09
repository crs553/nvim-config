return {
	"voldikss/vim-floaterm",

	keys = {
		-- Normal mode toggle
		{ "<M-i>", "<cmd>FloatermToggle<CR>", mode = "n", desc = "Toggle Floaterm" },
		-- Terminal mode toggle (need <C-\><C-n> to leave term mode first)
		{ "<M-i>", [[<C-\><C-n><cmd>FloatermToggle<CR>]], mode = "t", desc = "Toggle Floaterm" },
	},

	cmd = { "FloatermNew", "FloatermToggle", "FloatermSend" },

	init = function()
		-- Floaterm UI defaults
		vim.g.floaterm_width = 0.9
		vim.g.floaterm_height = 0.9
		vim.g.floaterm_wintype = "float"
		vim.g.floaterm_borderchars = "─│─│╭╮╯╰"

		-- Use PowerShell if running on Windows
		if vim.fn.has("win32") == 1 then
			vim.g.floaterm_shell = "powershell.exe"
		end
	end,
}
