vim.pack.add({
	{ src = "https://github.com/nvim-lua/plenary.nvim" },
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter" },
	{ src = "https://github.com/olimorris/codecompanion.nvim" },
})

require("codecompanion").setup({
	adapters = {
		ollama = function()
			return require("codecompanion.adapters").extend("ollama", {
				name = "ollama-local",
				url = "http://127.0.0.1:11434",
				schema = {
					model = "qwen3-coder",
				},
				stream = true,
			})
		end,
	},

	display = {
		chat = {
			icons = {
				chat_context = "📎️", -- You can also apply an icon to the fold
			},
			fold_context = true,
		},
	},

	strategies = {
		chat = { adapter = "ollama" },
		inline = {
			adapter = "ollama",
			keymaps = {
				accept = "<leader>ya",
				reject = "<leader>yr",
			},
		},
		agent = { adapter = "ollama" },
		cmd = { adapter = "ollama" },
	},

	interactions = {
		opts = {
			date_format = "%A, %d %B %Y", -- Example: "Monday, 01 January 2024"
			language = "English",
		},
		chat = {
			opts = {
				completion_provider = "cmp",
			},
		},
	},
})

-- =========================
-- KEYMAPS (Cursor-like workflow)
-- =========================

-- Open AI chat (Cursor-like sidebar)
vim.keymap.set("n", "<leader>ai", vim.cmd.CodeCompanionChat, {
	desc = "AI Chat",
	silent = true,
})

-- Inline AI on selection (visual mode)
vim.keymap.set("v", "<leader>ae", function()
	vim.cmd("CodeCompanionChat Add")
end, {
	desc = "AI: edit/explain selection",
	silent = true,
})

-- Open chat with immediate insert (buffer context prompt)
vim.keymap.set("n", "<leader>ac", function()
	vim.cmd("CodeCompanionChat")
	vim.cmd("startinsert")
end, {
	desc = "AI Chat (auto insert)",
	silent = true,
})

-- Actions menu (context-aware operations)
vim.keymap.set("n", "<leader>aa", vim.cmd.CodeCompanionActions, {
	desc = "AI Actions",
	silent = true,
})

-- Stop generation
vim.keymap.set("n", "<leader>as", vim.cmd.CodeCompanionStop, {
	desc = "Stop AI",
	silent = true,
})
