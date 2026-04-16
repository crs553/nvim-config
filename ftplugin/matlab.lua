local lopt = vim.opt_local
-- Comment string
lopt.commentstring = "% %s"

-- Indentation
lopt.tabstop = 4
lopt.shiftwidth = 4
lopt.expandtab = true

-- Folding
lopt.foldmethod = "indent"
lopt.foldenable = true
lopt.foldlevel = 99

lopt.filetype = "matlab"
