vim.pack.add({
  { src = "https://github.com/olimorris/codecompanion.nvim"},
  { src = "https://github.com/nvim-lua/plenary.nvim"},
  { src = "https://github.com/nvim-treesitter/nvim-treesitter" },
})

require("codecompanion").setup({
	adapters = {
		ollama = function()
			return require("codecompanion.adapters").extend("ollama", {
				name = "ollama-local",
				url = "http://127.0.0.1:11434",
				schema = {
					model = "qwen2.5-coder:7b",
				},

				options = {
					temperature = 0.2,
					top_p = 0.9,
				},
			})
		end,
	},

	strategies = {
		chat = {
			adapter = "ollama",
		},

		inline = {
			adapter = "ollama",
		},
	},
})

-- =========================
-- KEYMAPS (Cursor-like workflow)
-- =========================

-- Open AI chat (like Cursor chat sidebar)
vim.keymap.set("n", "<leader>ai", function()
	vim.cmd("CodeCompanionChat")
end, { desc = "Open AI Chat" })

-- Inline AI on selection (visual mode)
vim.keymap.set("v", "<leader>ae", function()
	vim.cmd("CodeCompanionChat Add")
end, { desc = "Explain / edit selection with AI" })

-- Quick prompt for current buffer
vim.keymap.set("n", "<leader>ap", function()
	vim.cmd("CodeCompanionChat")
	vim.cmd("startinsert")
end, { desc = "Prompt AI (buffer context)" })
