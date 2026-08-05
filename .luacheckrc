-- `vim` is the Neovim API; treat it as a writable global so that
-- `vim.opt`, `vim.opt_local`, `vim.fn`, `vim.api`, etc. all pass.
globals = { 'vim' }

max_line_length = 200
