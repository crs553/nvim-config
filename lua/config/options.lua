local opt = vim.opt

opt.number = true -- Print the line number in front of each line
opt.relativenumber = true -- Show line numbers relative to the cursor
opt.cursorline = true -- Highlight the line of the cursor
opt.wrap = true
opt.scrolloff = 10 -- keep 10 lines above and below the printer
opt.sidescrolloff = 10 -- keep 10 lines left/right of the cursor

-- Tabstops
opt.tabstop = 2 -- Number of spaces a <Tab> counts for
opt.shiftwidth = 2 -- Number of spaces per indentation
opt.softtabstop = 2 -- soft tab stop not tabs on tab/backspace
opt.expandtab = true -- Convert tabs to spaces
opt.smartindent = true
opt.autoindent = true -- Copy indent from current line when starting a new line

-- Text wrapping
opt.breakindent = true

-- search
opt.ignorecase = true -- case insensitive search
opt.smartcase = true -- case sensitive if upper case in string
opt.hlsearch = true -- highlight search matches
opt.incsearch = true -- show matches as you type

-- Preview substitutions
opt.signcolumn = "yes" -- akways show a signcolumn
opt.showmatch = true -- highlight matching brackets
opt.completeopt = "menuone,noinsert,noselect" -- completion o[tions
opt.showmode = false
opt.pumheight = 10
opt.pumblend = 10
opt.winblend = 0
opt.conceallevel = 0
opt.concealcursor = ""
opt.synmaxcol = 300
opt.inccommand = "split"
opt.fillchars = { eob = " " }

-- save undo history
opt.undofile = true
opt.autoread = true -- auto-reload changes if outside of neovim
opt.autowrite = false -- do not auto-save

opt.backspace = "indent,eol,start" -- better backspace behaviour
opt.path:append("*") --include subdirs in search
opt.selection = "inclusive" -- include last char in selection
opt.mouse = "a" -- enable mouse support
opt.clipboard:append("unnamedplus") -- use system clipboard
opt.encoding = "utf-8" -- set encoding

-- perceived (not measured) slowness on work pc
--opt.guicursor =	"n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50,a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor,sm:block-blinkwait175-blinkoff150-blinkon175"

-- Folding: requires treesitter available at runtime; safe fallback if not
opt.foldmethod = "expr" -- use expression for folding
opt.foldexpr = "v:lua.vim.treesitter.foldexpr()" -- use treesitter for folding
opt.foldlevel = 99 -- start with all folds open

opt.splitbelow = true -- horizontal split below
opt.splitright = true -- vertical splits are right

opt.title = true -- Set window title
opt.showcmd = true -- Show (partial) command in the last line

-- diagnostic tools for lsp
vim.diagnostic.config({
	virtual_text = true, -- Enable virtual text
	virtual_line = true,
	signs = true, -- Show signs in the gutter
	update_in_insert = false,
	underline = true,
	severity_sort = true,
})
