require("snacks").setup({
	bigfile = { enabled = true },
	image = { enabled = true },
	indent = { enabled = true },
	input = { enabled = true },
	notifier = { enabled = false },
	picker = { enabled = false }, -- replacing with telescope
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

-- Other
map.set("n", "<leader>.", function()
	S.scratch()
end, { desc = "Toggle Scratch Buffer" })
map.set("n", "<leader>S", function()
	S.scratch.select()
end, { desc = "Select Scratch Buffer" })
map.set("n", "<leader>bd", function()
	S.bufdelete()
end, { desc = "Delete Buffer" })
map.set("n", "<leader>br", function()
	S.rename.rename_file()
end, { desc = "Rename File" })
map.set({ "n", "x", "o" }, "<leader>gB", function()
	S.gitbrowse()
end, { desc = "Git Browse" })

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
