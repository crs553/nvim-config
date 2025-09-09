return {
	-- Mason for managing LSP servers
	{
		"mason-org/mason.nvim",
		opts = {},
	},

	-- Mason + lspconfig integration
	{
		"mason-org/mason-lspconfig.nvim",
		opts = { ensure_installed = { "lua_ls", "matlab_ls" } },
		dependencies = {
			{ "mason-org/mason.nvim", opts = {} },
			"neovim/nvim-lspconfig",
		},
	},

	-- LSP configuration
	{
		"neovim/nvim-lspconfig",
		config = function()
			local lspconfig = require("lspconfig")

			local on_attach = function(_, bufnr)
				vim.keymap.set("n", "<space>lh", vim.lsp.buf.hover, { desc = "Hover Info", buffer = bufnr })
			end

			lspconfig.lua_ls.setup({
				on_attach = on_attach,
			})
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
					-- Add Git's bin folder to PATH so make can find sh.exe
					local git_bin = "C:\\Users\\charlie\\AppData\\Local\\Programs\\Git\\bin"
					vim.env.PATH = git_bin .. ";" .. vim.env.PATH

					-- Run make with your GCC from Scoop
					local gcc_path = "C:\\Users\\charlie\\scoop\\apps\\gcc\\current\\bin\\gcc.exe"
					os.execute("make install_jsregexp CC=" .. gcc_path)
				end,
			},
		},
		config = function()
			local cmp = require("cmp")
			local luasnip = require("luasnip")

			-- Load VSCode-style snippets
			require("luasnip.loaders.from_vscode").lazy_load()

			cmp.setup({
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},
				mapping = cmp.mapping.preset.insert({
					["<C-Space>"] = cmp.mapping.complete(),
					["<CR>"] = cmp.mapping.confirm({ select = true }),
					["<Tab>"] = cmp.mapping.select_next_item(),
					["<S-Tab>"] = cmp.mapping.select_prev_item(),
				}),
				sources = cmp.config.sources({
					{ name = "nvim_lsp" },
					{ name = "luasnip" }, -- snippets
					{ name = "buffer" },
					{ name = "path" },
				}),
				experimental = {
					ghost_text = true, -- inline preview (similar to blink.cmp’s UX)
				},
			})

			-- Cmdline completion
			cmp.setup.cmdline({ "/", "?" }, {
				mapping = cmp.mapping.preset.cmdline(),
				sources = {
					{ name = "buffer" },
				},
			})

			cmp.setup.cmdline(":", {
				mapping = cmp.mapping.preset.cmdline(),
				sources = cmp.config.sources({
					{ name = "path" },
				}, {
					{ name = "cmdline" },
				}),
			})
		end,
	},

	-- conform.nvim for formatting
	{
		"stevearc/conform.nvim",
		config = function()
			require("conform").setup({
				formatters_by_ft = {
					lua = { "stylua" },
					python = { "black", "isort" },
				},
			})

			vim.api.nvim_create_autocmd("BufWritePre", {
				pattern = "*",
				callback = function()
					require("conform").format({ async = false })
				end,
			})
		end,
	},

	-- must be after mason and conform
	{
		"zapling/mason-conform.nvim",
		dependencies = { "mason-org/mason.nvim" },
		config = function()
			require("mason-conform").setup({})
		end,
	},
}
