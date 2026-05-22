-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.g.have_nerd_font = true

-- NixOS detection: skip mason to avoid dynamically linked binary issues
vim.g.is_nixos = (function()
	if vim.fn.has("linux") == 0 then return false end
	local ok, lines = pcall(vim.fn.readfile, "/etc/os-release")
	if not ok then return false end
	for _, l in ipairs(lines) do
		if l:match("^ID=nixos") or l:match('^ID="nixos"') then return true end
	end
	return false
end)()

require("plugins.whichkey")
require("config.keymaps")
require("config.autocmds")
require("config.options")
require("config.floaterm")
require("config.packclean")
require("config.git")

require("plugins.colorschemes")
require("plugins.comment")
require("plugins.conform")
require("plugins.dap")
require("plugins.gitsigns")
require("plugins.lspconfig")
require("plugins.lint") -- after lspconfig due to mason requirement
require("plugins.lualine")
require("plugins.markdown")
require("plugins.oil")
require("plugins.quicker")
require("plugins.snacks")
require("plugins.surround")
require("plugins.treesitter")
require("plugins.telescope")
require("plugins.undotree")
require("plugins.vimbegood")
require("plugins.ai") -- at end just to ensure cmp is setup
require("plugins.obsidian")
