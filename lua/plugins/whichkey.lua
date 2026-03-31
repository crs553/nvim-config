vim.pack.add({
    {
        src = "https://github.com/folke/which-key.nvim",
    }
})

-- Keymaps
vim.keymap.set("n", "<leader>?", function()
    require("which-key").show({ global = false })
end, { desc = "Buffer Local Keymaps (which-key)" })

vim.keymap.set("n", "<leader>ca", function()
    vim.lsp.buf.code_action()
end, { desc = "Code Action" })
