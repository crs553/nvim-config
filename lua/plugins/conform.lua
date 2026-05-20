vim.pack.add({
	{ src = "https://github.com/stevearc/conform.nvim" },
})

require("conform").setup({
	formatters_by_ft = {
		lua = { "stylua" },
		python = { "ruff_format", "ruff_organize_imports" },
		javascript = { "prettier" },
		typescript = { "prettier" },
		javascriptreact = { "prettier" },
		typescriptreact = { "prettier" },
		json = { "prettier" },
		jsonc = { "prettier" },
		yaml = { "prettier" },
		markdown = { "prettier" },
		html = { "prettier" },
		css = { "prettier" },
		bash = { "shfmt" },
		sh = { "shfmt" },
		rust = { "rustfmt" },
		matlab = { "matlab_ls" },
		-- go defaults to gopls formatting via LSP
	},
	format_on_save = {
		lsp_fallback = true,
		timeout_ms = 2000,
	},
})

-- Keymap: manually format buffer
vim.keymap.set({ "n", "x", "o" }, "<leader>cf", function()
	require("conform").format({
		lsp_fallback = true,
		timeout_ms = 2000,
	})
end, { desc = "Format buffer" })
