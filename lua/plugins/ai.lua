vim.pack.add({
	{ src = "https://github.com/nvim-lua/plenary.nvim" },
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter" },
	{ src = "https://github.com/olimorris/codecompanion.nvim", version = "v19.13.0" },
	{ src = "https://github.com/nvim-mini/mini.diff" },
})
require("mini.diff").setup()

require("codecompanion").setup({
	adapters = {
		copilot = false,
		acp = {
			opencode = function()
				return require("codecompanion.adapters").extend("opencode", {
					command = {
						default = {
							"opencode",
							"acp",
						},
					},
				})
			end,
		},
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

	interactions = {
		cli = {
			agent = "open_code",
			agents = {
				open_code = {
					cmd = "opencode",
					description = "Open Opencode CLI",
					provider = "terminal",
					auto_insert = true, -- Enter insert mode when focusing the CLI terminal
					reload = true, -- Reload buffers when an agent modifies files on disk
				},
			},
		},
		cmd = { adapter = "ollama" },
		chat = {
			adapter = "opencode",
			auto_apply = false,
			icons = {
				chat_context = "💬", -- You can also apply an icon to the fold
				chat_fold = " ",
			},
			fold_context = true,
			fold_reasoning = false,
			opts = {
				completion_provider = "default",
			},
			show_reasoning = true,
		},
		inline = {
			adapter = "ollama",
			keymaps = {
				accept = "<leader>ya",
				reject = "<leader>yr",
			},
		},
		agent = {
			adapter = "opencode",
		},
		background = {
			chat = {
				callbacks = {
					["on_ready"] = {
						actions = {
							"interactions.background.builtin.chat_make_title",
						},
						enabled = true,
					},
				},
				opts = {
					enabled = true,
				},
			},
		},
		opts = {
			date_format = "%A, %d %B %Y",
			log_level = "Debug",
			language = "British English",
			per_project_config = {
				files = {
					".codecompanion.lua",
				},
			},
			test_mode = true,
		},
	},

	display = {
		action_palette = {
			provider = "default",
		},
		diff = {
			provider = "mini_diff",
		},
	},

	prompt_library = {
		markdown = {
			dirs = {
				vim.fn.getcwd() .. "/.prompts",
				"~/.dotfiles/.config/prompts",
			},
		},
	},
})

vim.api.nvim_create_autocmd("User", {
	pattern = "CodeCompanionChatCreated",
	callback = function(args)
		local chat = require("codecompanion").buf_get_chat(args.data.bufnr)
		chat:add_callback("on_checkpoint", function(c, data)
			local context_window = data.adapter.meta and data.adapter.meta.context_window
			if not context_window then
				return
			end

			local usage = data.estimated_tokens / context_window
			if usage > 0.8 then
				vim.notify(string.format("Context window %.0f%% full", usage * 100), vim.log.levels.WARN)
				-- Compact data.messages in-place here
			end
		end)
	end,
})

local spinner = {
	completed = "󰗡 Completed",
	error = " Error",
	cancelled = "󰜺 Cancelled",
}

---Format the adapter name and model for display with the spinner
---@param adapter CodeCompanion.Adapter
---@return string
local function format_adapter(adapter)
	local parts = {}
	table.insert(parts, adapter.formatted_name)
	if adapter.model and adapter.model ~= "" then
		table.insert(parts, "(" .. adapter.model .. ")")
	end
	return table.concat(parts, " ")
end

---Setup the spinner for CodeCompanion
---@return nil
local function codecompanion_spinner()
	local ok, progress = pcall(require, "fidget.progress")
	if not ok then
		return
	end

	spinner.handles = {}

	local group = vim.api.nvim_create_augroup("dotfiles.codecompanion.spinner", {})

	vim.api.nvim_create_autocmd("User", {
		pattern = "CodeCompanionRequestStarted",
		group = group,
		callback = function(args)
			local handle = progress.handle.create({
				title = "",
				message = "  Sending...",
				lsp_client = {
					name = format_adapter(args.data.adapter),
				},
			})
			spinner.handles[args.data.id] = handle
		end,
	})

	vim.api.nvim_create_autocmd("User", {
		pattern = "CodeCompanionRequestFinished",
		group = group,
		callback = function(args)
			local handle = spinner.handles[args.data.id]
			spinner.handles[args.data.id] = nil
			if handle then
				if args.data.status == "success" then
					handle.message = spinner.completed
				elseif args.data.status == "error" then
					handle.message = spinner.error
				else
					handle.message = spinner.cancelled
				end
				handle:finish()
			end
		end,
	})
end

-- =========================
-- KEYMAPS (Cursor-like workflow)
-- =========================

-- Stop generation
vim.keymap.set("n", "<leader>as", vim.cmd.CodeCompanionStop, {
	desc = "Stop AI",
	silent = true,
})

vim.keymap.set("v", "<leader>ad", function()
	require("codecompanion").prompt("docstrings")
end, { desc = "Write docstring and comments for selection" })

vim.keymap.set("v", "<leader>ae", function()
	require("codecompanion").prompt("explain")
end, { desc = "Explain the selection" })

vim.keymap.set("n", "<leader>ag", function()
	require("codecompanion").prompt("commit")
end, { desc = "Generate commit message" })

vim.keymap.set("v", "<leader>af", function()
	require("codecompanion").prompt("fix")
end, { desc = "Fix this code" })

vim.keymap.set("v", "<leader>ai", function()
	require("codecompanion").prompt("inline")
end, { desc = "Inline prompt" })

vim.keymap.set("n", "<leader>aa", "<cmd>CodeCompanionActions<cr>", { desc = "CodeCompanion actions", silent = true })

codecompanion_spinner()
