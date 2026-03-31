-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.g.have_nerd_font = true
require("config.keymaps")
require("config.autocmds")
require("config.options")

require("plugins.catppuccin")
require("plugins.floaterm")
require("plugins.lspconfig")
require("plugins.lualine")
require("plugins.markdown")
require("plugins.oil")
require("plugins.snacks")
require("plugins.surround")
require("plugins.undotree")
require("plugins.vimbegood")
require("plugins.whichkey")
