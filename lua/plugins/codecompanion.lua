vim.pack.add({
	{ src = "https://github.com/nvim-lua/plenary.nvim" },
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter" },
	{ src = "https://github.com/olimorris/codecompanion.nvim" },
	{ src = "https://github.com/nvim-mini/mini.diff" },
})
require("mini.diff").setup()

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
		action_palette = {
			provider = "default",
		},
		chat = {
			icons = {
				chat_context = "📎️",
			},
			fold_context = true,
		},
		diff = {
			provider = "mini_diff",
		},
	},

	strategies = {
		chat = {
			adapter = "ollama",
			model = "qwen3-coder",
		},
		inline = {
			adapter = "ollama",
			keymaps = {
				accept = "<leader>ya",
				reject = "<leader>yr",
			},
		},
		--agent = { adapter = "ollama" },
		cmd = { adapter = "ollama" },
		background = {
			chat = {
				opts = {
					enabled = true,
				},
			},
		},
	},

	interactions = {
		opts = {
			date_format = "%A, %d %B %Y",
			log_level = "Debug",
			language = "British English",
		},

		chat = {
			opts = {
				completion_provider = "cmp",
			},
		},
	},
	prompt_library = {
		["Generate Docstrings"] = {
			interaction = "inline",
			description = "Generate docstrings for code",
			opts = {
				alias = "docstrings",
				auto_submit = true,
				ignore_system_prompt = false,
				modes = { "v" },
				placement = "replace",
				stop_context_insertion = true,
			},

			prompts = {
				{
					role = "system",
					content = [[
You are a code documentation assistant.

Your task is to add or update docstrings in code.

STRICT RULES:
- Only modify or add docstrings
- Do NOT change logic, structure, variable names, or formatting
- Follow the language's standard docstring conventions (e.g. PEP 257 for Python)
- Be concise, clear, and idiomatic
- Do not include explanations inside the code

OUTPUT FORMAT (must follow exactly):
1. MODIFIED CODE
2. CHANGELOG (bullet points describing changes only)
        ]],
				},

				{
					role = "user",
					content = function(context)
						local text =
							require("codecompanion.helpers.actions").get_code(context.start_line, context.end_line)

						-- Optional safety guard for large selections
						if #text > 12000 then
							return "Code selection too large. Please select a smaller section."
						end

						return table.concat({
							"Add docstrings to the following code.",
							"",
							"RULES:",
							"- Only add or update docstrings",
							"- Do NOT modify logic or structure",
							"- Return output in the required format",
							"",
							"CODE:",
							"```" .. context.filetype,
							text,
							"```",
						}, "\n")
					end,
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
vim.keymap.set({ "n", "v" }, "<leader>aa", vim.cmd.CodeCompanionActions, {
	desc = "AI Actions",
	silent = true,
})

-- Stop generation
vim.keymap.set("n", "<leader>as", vim.cmd.CodeCompanionStop, {
	desc = "Stop AI",
	silent = true,
})

vim.keymap.set("v", "<leader>ad", function()
	require("codecompanion").prompt("docstring")
end, { desc = "Write docstring and comments for selection" })
