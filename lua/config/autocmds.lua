-- Highlight yanked text with background
local au_group = vim.api.nvim_create_augroup("UserConfig", { clear = true })

-- Create autocmd to highlight yanked text
vim.api.nvim_create_autocmd("TextYankPost", {
	--- Highlight the yanked text
	desc = "Highlight when yanking (copying) text",
	group = au_group,
	callback = function()
		--- Highlight the last yanked text
		vim.highlight.on_yank()
	end,
})

vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
	callback = function()
		if vim.o.diff then -- except in diff mode
			return
		end

		local last_pos = vim.api.nvim_buf_get_mark(0, '"') -- {line, col}
		local last_line = vim.api.nvim_buf_line_count(0)

		local row = last_pos[1]
		if row < 1 or row > last_line then
			return
		end

		pcall(vim.api.nvim_win_set_cursor, 0, last_pos)
	end,
})

-- wrap, linebreak and spellcheck on markdown and text files
vim.api.nvim_create_autocmd("FileType", {
	group = au_group,
	pattern = { "markdown", "text", "gitcommit" },
	callback = function()
		vim.opt_local.wrap = true
		vim.opt_local.linebreak = true
		vim.opt_local.spell = true
	end,
})

vim.api.nvim_create_autocmd("LspDetach", {
	group = vim.api.nvim_create_augroup("MatlabLspRestart", { clear = true }),
	callback = function(args)
		if vim.bo[args.buf].filetype == "matlab" then
			vim.schedule(function()
				vim.lsp.enable("matlab_ls")
			end)
		end
	end,
})

-- make neovim help or a man page always open in vertical split
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "help", "man" },
	command = "wincmd L",
})
