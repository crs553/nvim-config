vim.pack.add({
	{ src = "https://github.com/folke/snacks.nvim" },
})

require("snacks").setup({
	bigfile = { enabled = true },
	image = { enabled = true },
	indent = { enabled = true },
	input = { enabled = true },
	notifier = { enabled = true, timeout = 3000 },
	picker = { enabled = true },
	quickfile = { enabled = true },
	scope = { enabled = true },
	scroll = { enabled = true },
	statuscolumn = { enabled = true },
	words = { enabled = true },
	styles = { notification = { wo = { wrap = true } } },
})

-- Keymaps
local S = require("snacks")
local map = vim.keymap

-- Top Pickers & Explorer
map.set("n", "<leader>:", function()
	S.picker.command_history()
end, { desc = "Command History" })
map.set("n", "<leader>fn", function()
	S.picker.notifications()
end, { desc = "Find Notification History" })

-- Find
map.set("n", "<leader>fb", function()
	S.picker.buffers()
end, { desc = "Buffers" })
map.set("n", "<leader>fc", function()
	S.picker.files({ cwd = vim.fn.stdpath("config") })
end, { desc = "Find Config File" })
map.set("n", "<leader>fd", function()
	S.picker.files()
end, { desc = "Find Files" })
map.set("n", "<leader>fg", function()
	S.picker.git_files()
end, { desc = "Find Git Files" })
map.set("n", "<leader>fp", function()
	S.picker.projects()
end, { desc = "Projects" })
map.set("n", "<leader>fr", function()
	S.picker.recent()
end, { desc = "Recent" })
map.set("n", "<leader>fs", function()
	S.picker.grep()
end, { desc = "Grep" })
map.set("n", "<leader>fh", function()
	S.picker.help()
end, { desc = "Help Pages" })
map.set("n", "<leader>fq", function()
	S.picker.grep({ buffers = true })
end, { desc = "Search in open buffers" })
map.set("n", "<leader>fk", function()
	S.picker.keymaps()
end, { desc = "Search Keymaps" })

-- Git
map.set("n", "<leader>gb", function()
	S.picker.git_branches()
end, { desc = "Git Branches" })
map.set("n", "<leader>gl", function()
	S.picker.git_log()
end, { desc = "Git Log" })
map.set("n", "<leader>gL", function()
	S.picker.git_log_line()
end, { desc = "Git Log Line" })
map.set("n", "<leader>gs", function()
	S.picker.git_status()
end, { desc = "Git Status" })
map.set("n", "<leader>gS", function()
	S.picker.git_stash()
end, { desc = "Git Stash" })
map.set("n", "<leader>gd", function()
	S.picker.git_diff()
end, { desc = "Git Diff (Hunks)" })
map.set("n", "<leader>gf", function()
	S.picker.git_log_file()
end, { desc = "Git Log File" })

-- Grep/Search
map.set("n", "<leader>sb", function()
	S.picker.lines()
end, { desc = "Buffer Lines" })
map.set("n", "<leader>sB", function()
	S.picker.grep_buffers()
end, { desc = "Grep Open Buffers" })
map.set({ "n", "x" }, "<leader>sw", function()
	S.picker.grep_word()
end, { desc = "Visual selection or word" })
map.set("n", '<leader>s"', function()
	S.picker.registers()
end, { desc = "Registers" })
map.set("n", "<leader>s/", function()
	S.picker.search_history()
end, { desc = "Search History" })
map.set("n", "<leader>sa", function()
	S.picker.autocmds()
end, { desc = "Autocmds" })

-- LSP
map.set("n", "grd", function()
	S.picker.lsp_definitions()
end, { desc = "Goto Definition" })
map.set("n", "grD", function()
	S.picker.lsp_declarations()
end, { desc = "Goto Declaration" })
map.set("n", "grx", function()
	S.picker.lsp_references()
end, { nowait = true, desc = "References" })
map.set("n", "gri", function()
	S.picker.lsp_implementations()
end, { desc = "Goto Implementation" })
map.set("n", "gry", function()
	S.picker.lsp_type_definitions()
end, { desc = "Goto T[y]pe Definition" })
map.set("n", "grs", function()
	S.picker.lsp_symbols()
end, { desc = "LSP Symbols" })
map.set("n", "grS", function()
	S.picker.lsp_workspace_symbols()
end, { desc = "LSP Workspace Symbols" })

-- Other
map.set("n", "<leader>z", function()
	S.zen()
end, { desc = "Toggle Zen Mode" })
map.set("n", "<leader>.", function()
	S.scratch()
end, { desc = "Toggle Scratch Buffer" })
map.set("n", "<leader>S", function()
	S.scratch.select()
end, { desc = "Select Scratch Buffer" })
map.set("n", "<leader>bd", function()
	S.bufdelete()
end, { desc = "Delete Buffer" })
map.set("n", "<leader>cR", function()
	S.rename.rename_file()
end, { desc = "Rename File" })
map.set({ "n", "x", "o" }, "<leader>gB", function()
	S.gitbrowse()
end, { desc = "Git Browse" })
map.set("n", "<leader>un", function()
	S.notifier.hide()
end, { desc = "Dismiss All Notifications" })
map.set("n", "<c-_>", function()
	S.terminal()
end, { desc = "which_key_ignore" })
map.set({ "n", "t" }, "]]", function()
	S.words.jump(vim.v.count1)
end, { desc = "Next Reference" })
map.set({ "n", "t" }, "[[", function()
	S.words.jump(-vim.v.count1)
end, { desc = "Prev Reference" })
map.set("n", "<leader>N", function()
	S.win({
		file = vim.api.nvim_get_runtime_file("doc/news.txt", false)[1],
		width = 0.6,
		height = 0.6,
		wo = { spell = false, wrap = false, signcolumn = "yes", statuscolumn = " ", conceallevel = 3 },
	})
end, { desc = "Neovim News" })

-- Init / Lazy setup
vim.api.nvim_create_autocmd("User", {
	pattern = "VeryLazy",
	callback = function()
		_G.dd = function(...)
			S.debug.inspect(...)
		end
		_G.bt = function()
			S.debug.backtrace()
		end
		vim.print = _G.dd

		-- Toggle mappings
		S.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
		S.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
		S.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
		S.toggle.diagnostics():map("<leader>ud")
		S.toggle.line_number():map("<leader>ul")
		S.toggle
			.option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 })
			:map("<leader>uc")
		S.toggle.treesitter():map("<leader>uT")
		S.toggle.option("background", { off = "light", on = "dark", name = "Dark Background" }):map("<leader>ub")
		S.toggle.inlay_hints():map("<leader>uh")
		S.toggle.indent():map("<leader>ug")
		S.toggle.dim():map("<leader>uD")
	end,
})
