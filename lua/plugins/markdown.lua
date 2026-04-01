vim.pack.add({
  { src = "https://github.com/nvim-treesitter/nvim-treesitter" },
  { src = "https://github.com/echasnovski/mini.nvim" },
  { src = "https://github.com/tadmccorkle/markdown.nvim" },
  { src = "https://github.com/MeanderingProgrammer/render-markdown.nvim" },
})

-- Setup markdown.nvim on markdown files
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    require("markdown").setup({})

    -- Setup render-markdown after markdown.nvim is loaded
    require("render-markdown").setup({
      latex = {
        enabled = true,
        render_modes = true,
        converter = { "latex2text" },
        highlight = "RenderMarkdownMath",
        position = "center", -- above / below / center
        top_pad = 0,
        bottom_pad = 0,
      },
      completions = {
        lsp = { enabled = true },
      },
    })
  end,
})
