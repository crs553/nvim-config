return {

	-- Mason
	{
		"mason-org/mason.nvim",
		opts = {},
	},

	-- Mason + lspconfig integration
	{
		"mason-org/mason-lspconfig.nvim",
		opts = {
			ensure_installed = {
				"lua_ls",
				"matlab_ls",
				"gopls",
				"pylsp", -- Python LSP (mypy comes via plugin)
				"marksman",
				"ltex_plus",
			},
		},
		dependencies = {
			{ "mason-org/mason.nvim", opts = {} },
			"neovim/nvim-lspconfig",
		},
	},

	-- LSP configuration
	{
		"neovim/nvim-lspconfig",
		config = function()
			local capabilities = vim.lsp.protocol.make_client_capabilities()
			capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

			local on_attach = function(_, bufnr)
				local map = function(mode, keys, func, desc)
					vim.keymap.set(mode, keys, func, { buffer = bufnr, desc = "LSP: " .. desc })
				end

				map("n", "<space>lh", vim.lsp.buf.hover, "Hover")
				map("n", "<space>ld", vim.lsp.buf.definition, "Go to definition")
				map("n", "<space>lr", vim.lsp.buf.rename, "Rename symbol")
			end

			-- Lua
			vim.lsp.config["lua_ls"] = {
				on_attach = on_attach,
				capabilities = capabilities,
				filetypes = { "lua" },
				settings = {
					Lua = {
						workspace = { checkThirdParty = false },
						telemetry = { enable = false },
					},
				},
			}
			vim.lsp.enable("lua_ls")

			vim.lsp.config["ltex_plus"] = {
				on_attach = on_attach,
				capabilities = capabilities,
				settings = {
					ltex = {
						language = "en-GB", -- British English
						diagnosticSeverity = "information",
						disabledRules = { "MORFOLOGIK_RULE_EN_GB", "OXFORD_SPELLING_NOUNS" },
						dictionary = {
							["en-GB"] = { "Neovim", "Lua", "Eurospin", "radiofrequency", "MagIQ" }, -- add your custom words
						},
						setPreferences = {
							["variant"] = "GB", -- enforce standard British English
							["allowVariants"] = false, -- prevent Oxford-style suggestions
						},
						sentenceCacheSize = 2000,
					},
				},
				filetypes = { "markdown", "tex", "text", "gitcommit", "bib" },
			}
			vim.lsp.enable("ltex_plus")

			vim.lsp.config["matlab_ls"] = {
				filetypes = { "matlab" },
				settings = {
					MATLAB = {
						installPath = "C:\\Program Files\\MATLAB\\R2024a\\",
						matlabConnectionTiming = "onStart",
						telemetry = true,
						verboseLogging = true,
						mlintpath = "C:\\Program Files\\MATLAB\\R2024b\\bin\\win64\\mlint.exe",
					},
				},
				on_attach = on_attach,
				capabilities = capabilities,
				single_file_support = true,
			}
			vim.lsp.enable("matlab_ls")

			-- Python (pylsp + mypy plugin)
			vim.lsp.config["pylsp"] = {
				on_attach = on_attach,
				capabilities = capabilities,
				settings = {
					pylsp = {
						plugins = {
							pycodestyle = { enabled = false }, -- disable in favor of black
							mypy = {
								enabled = true,
								live_mode = true, -- type-check as you type
								dmypy = true, -- use daemon if available

								struct = true,
								report_progress = true,
							},
							black = { enabled = true }, -- formatting handled by Conform
							isort = { enabled = true }, -- formatting not handled by Conform
						},
					},
				},
			}
			vim.lsp.enable("pylsp")

			-- Go
			vim.lsp.config["gopls"] = {
				on_attach = on_attach,
				capabilities = capabilities,
			}
			vim.lsp.enable("gopls")
		end,
	},

	-- nvim-cmp for autocompletion
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-cmdline",
			"rafamadriz/friendly-snippets", -- optional snippet collection
			{
				"L3MON4D3/LuaSnip",
				build = function()
					local git_bin = "C:\\Users\\charlie\\AppData\\Local\\Programs\\Git\\bin"
					vim.env.PATH = git_bin .. ";" .. vim.env.PATH

					local gcc_path = "C:\\Users\\charlie\\scoop\\apps\\gcc\\current\\bin\\gcc.exe"
					os.execute("make install_jsregexp CC=" .. gcc_path)
				end,
			},
		},
		config = function()
			local cmp = require("cmp")
			local luasnip = require("luasnip")

			require("luasnip.loaders.from_vscode").lazy_load()

			cmp.setup({
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},

				mapping = cmp.mapping.preset.insert({
					["<C-n>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_next_item()
						else
							fallback()
						end
					end, { "i", "c" }),

					["<C-p>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_prev_item()
						else
							fallback()
						end
					end, { "i", "c" }),

					["<C-b>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),

					-- Confirm the currently selected item
					["<C-y>"] = cmp.mapping.confirm({ select = true }),

					["<C-e>"] = cmp.mapping.abort(),
					["<CR>"] = cmp.mapping.confirm({ select = false }),
				}),

				sources = cmp.config.sources({
					{ name = "nvim_lsp" },
					{ name = "luasnip" },
					{ name = "buffer" },
					{ name = "path" },
				}),
				experimental = { ghost_text = true },
			})

			cmp.setup.cmdline({ "/", "?" }, {
				mapping = cmp.mapping.preset.cmdline(),
				sources = { { name = "buffer" } },
			})

			cmp.setup.cmdline(":", {
				mapping = cmp.mapping.preset.cmdline(),
				sources = cmp.config.sources({ { name = "path" } }, { { name = "cmdline" } }),
			})
		end,
	},
}
