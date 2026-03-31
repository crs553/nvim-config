vim.pack.add({
    {
        src = "https://github.com/voldikss/vim-floaterm",
    }
})

-- Floaterm setup
vim.g.floaterm_width = 0.9
vim.g.floaterm_height = 0.9
vim.g.floaterm_wintype = "float"
vim.g.floaterm_borderchars = "─│─│╭╮╯╰"

-- Use PowerShell if running on Windows
if vim.fn.has("win32") == 1 then
    vim.g.floaterm_shell = "powershell.exe"
end

-- Keymaps
-- Normal mode toggle
vim.keymap.set("n", "<M-i>", "<cmd>FloatermToggle<CR>", { desc = "Toggle Floaterm" })
-- Terminal mode toggle (need <C-\><C-n> to leave term mode first)
vim.keymap.set("t", "<M-i>", [[<C-\><C-n><cmd>FloatermToggle<CR>]], { desc = "Toggle Floaterm" })
