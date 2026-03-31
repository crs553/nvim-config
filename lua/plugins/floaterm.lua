vim.pack.add({
  {
    src = "https://github.com/voldikss/vim-floaterm",
  }
})

vim.g.floaterm_width = 0.9
vim.g.floaterm_height = 0.9
vim.g.floaterm_wintype = "float"
vim.g.floaterm_borderchars = "─│─│╭╮╯╰"

if vim.fn.has("win32") == 1 then
  vim.g.floaterm_shell = "powershell.exe"
end

vim.keymap.set("n", "<M-i>", "<cmd>FloatermToggle<CR>", { desc = "Toggle Floaterm" })
vim.keymap.set("t", "<M-i>", [[<C-\><C-n><cmd>FloatermToggle<CR>]], { desc = "Toggle Floaterm" })
