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

-- search unless \C or one or more captials in search term
opt.ignorecase = true -- case insensitive search
opt.smartcase = true -- case sensitive if upper case in string
opt.hlsearch = true -- highlight search matches
opt.incsearch = true -- show matches as you type

-- Decrease update time
opt.updatetime = 250

-- Decrease mapped sentense waittime
opt.timeoutlen = 300

-- Preview substitutions
opt.signcolumn = 'yes' -- akways show a signcolumn
opt.showmatch = true -- highlight matching brackets
opt.completeopt = 'menuone,noinsert,noselect' -- completion o[tions
opt.showmode = false
opt.pumheight = 10
opt.pumblend = 10
opt.winblend = 0
opt.conceallevel = 0
opt.concealcursor = ''
opt.synmaxcol = 300 -- Preview substitutions live when typing
opt.inccommand = 'split'
opt.fillchars = { eob = ' ' }

-- if performing an operation that would fail due to unsaved changes in the buffer (like `:q`),
-- instead raise a dialog asking if you wish to save the current file(s)
-- See `:help 'confirm'`
vim.o.confirm = true

-- save undo history even after closing files
opt.undofile = true
opt.autoread = true -- auto-reload changes if outside of neovim
opt.autowrite = false -- do not auto-save

opt.backspace = 'indent,eol,start' -- better backspace behaviour
opt.path:append '*' --include subdirs in search
opt.selection = 'inclusive' -- include last char in selection
opt.mouse = 'a' -- enable mouse support

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
--
--  Notice listchars is set using `vim.opt` instead of `vim.o`.
--  It is very similar to `vim.o` but offers an interface for conveniently interacting with tables.
--   See `:help lua-options`
--   and `:help lua-guide-options`
vim.o.list = true
opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Folding: requires treesitter available at runtime; safe fallback if not
opt.foldmethod = 'expr' -- use expression for folding
opt.foldexpr = 'nvim_treesitter#foldexpr()' -- use treesitter for folding
opt.foldlevel = 99 -- start with all folds open

opt.splitbelow = true -- horizontal split below
opt.splitright = true -- vertical splits are right

opt.title = true -- Set window title
opt.showcmd = true -- Show (partial) command in the last line

-- diagnostic tools for lsp
vim.diagnostic.config {
  virtual_text = false,
  virtual_line = true,

  signs = true,

  update_in_insert = true,

  underline = { severity = { min = vim.diagnostic.severity.WARN } },

  severity_sort = true,
  float = {
    border = 'rounded',
    source = 'if_many',
  },

  -- Auto open the float, so you can easily read the errors when jumping with `[d` and `]d`
  jump = {
    on_jump = function(_, bufnr)
      vim.diagnostic.open_float {
        bufnr = bufnr,
        scope = 'cursor',
        focus = false,
      }
    end,
  },
}

-- Inlay hints (enabled by default, toggle with <leader>uh)
vim.lsp.inlay_hint.enable(true, nil)

-- Experimental ui for neovim
--require("vim._core.ui2").enable({})
