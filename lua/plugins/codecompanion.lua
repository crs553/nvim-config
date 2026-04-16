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
				chat_context = "📎️",
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
		--agent = { adapter = "ollama" },
		cmd = { adapter = "ollama" },
	},

	interactions = {
		opts = {
			date_format = "%A, %d %B %Y",
			language = "English",
		},

		chat = {
			opts = {
				completion_provider = "cmp",
			},
		},
	},

	prompt_library = {
		docstring = {
			strategy = "inline",
			description = "Adds a docstring and inline comments to the selected function",
			opts = {
				placement = "before",
			},
			prompts = {
				{
					role = "user",
					content = "Write a clear docstring and add helpful inline comments for:\n\n{{selection}}",
				},
			},
		},

		refactor = {
			strategy = "inline",
			description = "Improve structure, readability, and naming",
			opts = { placement = "after" },
			prompts = {
				{
					role = "user",
					content = "Refactor this code for clarity and maintainability:\n\n{{selection}}",
				},
			},
		},

		explain = {
			strategy = "chat",
			description = "Explain selected code",
			prompts = {
				{
					role = "user",
					content = "Explain what this code does step by step:\n\n{{selection}}",
				},
			},
		},

		bugs = {
			strategy = "chat",
			description = "Detect issues in code",
			prompts = {
				{
					role = "user",
					content = "Find bugs, edge cases, and potential runtime issues:\n\n{{selection}}",
				},
			},
		},

		optimize = {
			strategy = "inline",
			description = "Make code faster and reduce allocations",
			prompts = {
				{
					role = "user",
					content = "Optimize this code for performance. Explain tradeoffs in comments:\n\n{{selection}}",
				},
			},
		},

		tests = {
			strategy = "chat",
			description = "Generate unit tests",
			prompts = {
				{
					role = "user",
					content = "Generate comprehensive unit tests for this code:\n\n{{selection}}",
				},
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

vim.keymap.set("v", "<leader>cd", function()
	require("codecompanion").prompt("Write docstring and comments for function")
end, { desc = "Write docstring and comments for selection" })
