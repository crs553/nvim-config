-- LSP config
vim.pack.add({ { src = "https://github.com/neovim/nvim-lspconfig" } })

-- Mason
vim.pack.add({ { src = "https://github.com/williamboman/mason.nvim" } })
vim.pack.add({ { src = "https://github.com/williamboman/mason-lspconfig.nvim" } })

-- CMP + Snippets
vim.pack.add({
	{ src = "https://github.com/hrsh7th/nvim-cmp" },
	{ src = "https://github.com/hrsh7th/cmp-nvim-lsp" },
	{ src = "https://github.com/hrsh7th/cmp-buffer" },
	{ src = "https://github.com/hrsh7th/cmp-path" },
	{ src = "https://github.com/hrsh7th/cmp-cmdline" },
	{ src = "https://github.com/L3MON4D3/LuaSnip" },
	{ src = "https://github.com/rafamadriz/friendly-snippets" },
	-- DISABLED DUE TO SLOWNESS WITH LOCAL MODEL{ src = "https://github.com/tzachar/cmp-ai" },
})

-- ======================
-- Mason Setup
-- ======================
require("mason").setup()
require("mason-lspconfig").setup({
	ensure_installed = {
		"bashls",
		"lua_ls",
		"pylsp",
		"marksman",
		"ltex_plus",
		"gopls",
		"arduino_language_server",
		"stylua",
	},
})

-- ======================
-- LSP Capabilities & on_attach
-- ======================
local has_cmp_lsp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if not has_cmp_lsp then
	vim.notify("cmp_nvim_lsp not found!", vim.log.levels.WARN)
	return
end

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = cmp_nvim_lsp.default_capabilities(capabilities)

local on_attach = function(_, bufnr)
	local map = function(mode, keys, func, desc)
		vim.keymap.set(mode, keys, func, { buffer = bufnr, desc = "LSP: " .. desc })
	end

	map("n", "<leader>lh", vim.lsp.buf.hover, "Hover")
	map("n", "<leader>ld", vim.lsp.buf.definition, "Definition")
	map("n", "<leader>lr", vim.lsp.buf.rename, "Rename")
	map("n", "<leader>ca", vim.lsp.buf.code_action, "Code Action")
	map("n", "grf", vim.lsp.buf.format, "Format Buffer")
	map("n", "<leader>sh", vim.lsp.buf.signature_help, "Signature Help")
end

vim.lsp.enable("bashls")
-- ======================
-- LSP Servers (vim.lsp.config API)
-- ======================

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
vim.lsp.enable("stylua")

-- LTEX Plus
vim.lsp.config["ltex_plus"] = {
	on_attach = on_attach,
	capabilities = capabilities,
	filetypes = { "markdown", "tex", "text", "gitcommit", "bib" },
	settings = {
		ltex = {
			language = "en-GB",
			diagnosticSeverity = "information",
			disabledRules = { "MORFOLOGIK_RULE_EN_GB", "OXFORD_SPELLING_NOUNS" },
			dictionary = { ["en-GB"] = { "Neovim", "Lua", "Eurospin", "radiofrequency", "MagIQ" } },
			setPreferences = { variant = "GB", allowVariants = false },
			sentenceCacheSize = 2000,
		},
	},
}
vim.lsp.enable("ltex_plus")

-- MATLAB -- note I managed this externally as the Mason files were not working for me
vim.lsp.config["matlab_ls"] = {
	capabilities = capabilities,
	on_attach = on_attach,
	cmd = { "matlab-language-server", "--stdio" },
	root_dir = vim.loop.cwd,
	settings = {
		MATLAB = {
			indexWorkspace = true,
			installPath = "C:\\Program Files\\MATLAB\\R2025b",
			matlabConnectionTiming = "onStart",
			telemetry = true,
		},
	},
	single_file_support = true,
}
vim.lsp.enable("matlab_ls")

-- Python (pylsp + mypy)
vim.lsp.config["pylsp"] = {
	on_attach = on_attach,
	capabilities = capabilities,
	settings = {
		pylsp = {
			plugins = {
				pycodestyle = { enabled = false },
				mypy = { enabled = true, live_mode = true, dmypy = true, struct = true, report_progress = true },
				black = { enabled = true },
				isort = { enabled = true },
			},
		},
	},
}
vim.lsp.enable("pylsp")

-- Arduino Language Server
vim.lsp.config["arduino_language_server"] = {
	on_attach = on_attach,
	capabilities = capabilities,
	root_dir = vim.loop.cwd,
}
vim.lsp.enable("arduino_language_server")

--go files
vim.lsp.enable("gopls")

--DISABLED DUE TO LOCAL MODEL BEING TOO SLOW
-- ai code completion setup
--local cmp_ai = require("cmp_ai.config")
--cmp_ai:setup({
--	max_lines = 30, -- keep context small for speed
--
--	provider = "Ollama",
--
--	provider_options = {
--		model = "deepseek-coder:1.3b",
--
--		-- Qwen3-Coder benefits from FIM-style formatting
--		prompt = function(before, after)
--			return before .. "\n<fim_suffix>\n" .. after .. "\n<fim_middle>"
--		end,
--	},
--
--	-- IMPORTANT: avoid lag spikes consider changing to false
--	run_on_every_keystroke = false,
--	debounce_ms = 250,
--	notify = false,
--	notify_callback = function(msg)
--		vim.notify(msg)
--	end,
--
--	ignored_file_types = {
--		help = true,
--	},
--})

-- nvim-cmp Setup
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
		["<C-n>"] = cmp.mapping.select_next_item(),
		["<C-p>"] = cmp.mapping.select_prev_item(),
		["<C-b>"] = cmp.mapping.scroll_docs(-4),
		["<C-f>"] = cmp.mapping.scroll_docs(4),

		-- only accept with C-y
		["<C-y>"] = cmp.mapping.confirm({ select = true }),

		-- enter disabled for completion (always fallback newline)
		["<CR>"] = cmp.mapping(function(fallback)
			fallback()
		end, { "i", "s" }),

		["<C-e>"] = cmp.mapping.abort(),
	}),

	-- PRIORITY ORDER (AI first)
	sources = cmp.config.sources({
		{ name = "cmp_ai", priority = 1000 }, -- AI on top
		{ name = "nvim_lsp", priority = 800 },
		{ name = "luasnip", priority = 700 },
	}, {
		{ name = "buffer", priority = 500 },
		{ name = "path", priority = 300 },
	}),

	-- CLEAR LABELS IN MENU
	formatting = {
		format = function(entry, vim_item)
			vim_item.menu = ({
				cmp_ai = "🤖 AI",
				nvim_lsp = "🧠 LSP",
				luasnip = "✂️ Snip",
				buffer = "📄 Buf",
				path = "📁 Path",
			})[entry.source.name]

			return vim_item
		end,
	},

	-- BETTER SORTING (keeps AI stable at top)
	sorting = {
		priority_weight = 2,
		comparators = {
			require("cmp").config.compare.offset,
			require("cmp").config.compare.exact,
			require("cmp").config.compare.score,
			require("cmp").config.compare.recently_used,
			require("cmp").config.compare.kind,
			require("cmp").config.compare.sort_text,
			require("cmp").config.compare.length,
			require("cmp").config.compare.order,
		},
	},

	experimental = {
		ghost_text = true,
	},
}) -- CMP cmdline support
cmp.setup.cmdline({ "/", "?" }, { mapping = cmp.mapping.preset.cmdline(), sources = { { name = "buffer" } } })
cmp.setup.cmdline(":", {
	mapping = cmp.mapping.preset.cmdline(),
	sources = cmp.config.sources({ { name = "path" } }, { { name = "cmdline" } }),
})
