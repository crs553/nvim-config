local opt = vim.opt

opt.clipboard = "unnamedplus" -- Use system clipboard for all operations

opt.number = true             -- Print the line number in front of each line
opt.relativenumber = true     -- Show line numbers relative to the cursor

opt.signcolumn = 'yes' 

opt.cursorline = true         -- Highlight the line of the cursor

-- Show whitespace characters
opt.list = true
opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- search
opt.ignorecase = true
opt.smartcase = true

-- Preview substitutions
opt.inccommand = "split"

-- Text wrapping
opt.wrap = true
opt.breakindent = true

-- Tabstops
opt.expandtab = true          -- Convert tabs to spaces
opt.autoindent = true         -- Copy indent from current line when starting a new line
opt.tabstop = 2               -- Number of spaces a <Tab> counts for
opt.softtabstop = 2
opt.shiftwidth = 2            -- Number of spaces per indentation

opt.splitright = true
opt.splitbelow = true

-- save undo history
opt.undofile = true

opt.ruler = true              -- Show line and column number of the cursor
opt.title = true              -- Set window title
opt.showcmd = true            -- Show (partial) command in the last line
opt.showmatch = true          -- Briefly jump to matching bracket

-- diagnostic tools for lsp
vim.diagnostic.config({
  virtual_text = true, -- Enable virtual text
  signs = true,        -- Show signs in the gutter
  update_in_insert = false,
  underline = true,
  severity_sort = true,
})
