require("conform").setup({
	formatters_by_ft = {
		bash = { "shfmt" },
		css = { "biome" },
		go = { "goimports", "gofmt" },
		html = { "biome" },
		javascript = { "biome" },
		javascriptreact = { "biome" },
		json = { "biome" },
		jsonc = { "biome" },
		lua = { "stylua" },
		markdown = { "prettier" },
		python = { "ruff_format", "ruff_organize_imports" },
		rust = { "rustfmt" },
		sh = { "shfmt" },
		typescript = { "biome" },
		typescriptreact = { "biome" },
		yaml = { "prettier" },
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
