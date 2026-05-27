if not vim.g.is_nixos then
	require("mason-nvim-lint").setup({
		ensure_installed = {
			"markdownlint",
			"shellcheck",
			"yamllint",
			"jsonlint",
		},
		automatic_install = false,
	})
end

local lint = require("lint")

lint.linters_by_ft = {
	python = { "ruff" },
	--javascript = { "eslint" },
	--typescript = { "eslint" },
	--javascriptreact = { "eslint" },
	--typescriptreact = { "eslint" },
	-- lua = { "luacheck" }, -- doesn't work on windows
	sh = { "shellcheck" },
	zsh = { "shellcheck" },
	bash = { "shellcheck" },
	markdown = { "markdownlint" },
	yaml = { "yamllint" },
	json = { "jsonlint" },
}

-- Auto-lint on save and on insert leave
vim.api.nvim_create_autocmd({ "BufWritePost", "InsertLeave" }, {
	group = vim.api.nvim_create_augroup("nvim-lint", { clear = true }),
	callback = function()
		-- Only lint if the buffer has a matching filetype
		if lint.linters_by_ft[vim.bo.filetype] then
			lint.try_lint()
		end
	end,
})

-- Keymap: manually lint current buffer
vim.keymap.set("n", "<leader>ll", function()
	lint.try_lint()
end, { desc = "Lint buffer" })
