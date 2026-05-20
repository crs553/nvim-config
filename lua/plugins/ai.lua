vim.pack.add({
	{ src = "https://github.com/nvim-lua/plenary.nvim" },
	{ src = "https://github.com/olimorris/codecompanion.nvim", version = "v19.13.0" },
	{ src = "https://github.com/nvim-mini/mini.diff" },
})
require("mini.diff").setup()

require("codecompanion").setup({
	adapters = {
		acp = {
			opencode = function()
				return require("codecompanion.adapters").extend("opencode", {
					command = {
						default = {
							"opencode",
							"acp",
						},
					},
					model = "qwen2.5-coder-7b-instruct",
				})
			end,
		},
		http = {
			lmstudio = function()
				return require("codecompanion.adapters").extend("openai_compatible", {
					name = "lmstudio",

					env = {
						url = "http://127.0.0.1:1234",
						api_key = "lmstudio",
					},

					schema = {
						model = {
							default = "qwen2.5-coder-7b-instruct",
						},
					},

					stream = true,
				})
			end,
		},
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
		cmd = { adapter = "lmstudio" },
		chat = {
			adapter = "lmstudio",
			auto_apply = false,
			icons = {
				chat_context = "💬", -- You can also apply an icon to the fold
				chat_fold = " ",
			},
			fold_context = true,
			fold_reasoning = true,
			opts = {
				completion_provider = "default",
			},
			show_reasoning = true,
		},
		inline = {
			adapter = "lmstudio",
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
			test_mode = false,
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

require("plugins.ai_keymaps")
vim.cmd([[cab cc CodeCompanion]])
