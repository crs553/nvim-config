vim.pack.add({
	{ src = "https://github.com/stevearc/conform.nvim" },
})

require("conform").setup({
	formatters_by_ft = {
		bash = { "shfmt" },
		css = { "prettier" },
		go = { "goimports", "gofmt" }, -- Runs goimports first, then gofmt
		html = { "prettier" },
		javascript = { "prettier" },
		javascriptreact = { "prettier" },
		json = { "prettier" },
		jsonc = { "prettier" },
		lua = { "stylua" },
		markdown = { "prettier" },
		--matlab = { "matlab_ls" },
		python = { "ruff_format", "ruff_organize_imports" },
		rust = { "rustfmt" },
		sh = { "shfmt" },
		typescript = { "prettier" },
		typescriptreact = { "prettier" },
		yaml = { "prettier" },
		-- go defaults to gopls formatting via LSP
	},
	format_on_save = {
		lsp_fallback = true,
		timeout_ms = 2000,
	},
})

-- Keymap: manually format buffer
vim.keymap.set({ "n", "x", "o" }, "<leader>lf", function()
	require("conform").format({
		lsp_fallback = true,
		timeout_ms = 2000,
	})
end, { desc = "Format buffer" })
