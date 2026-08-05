-- Setup markdown.nvim once (not per-buffer), then render-markdown
local setup_done = false

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'markdown',
  callback = function()
    if setup_done then return end
    setup_done = true

    require('markdown').setup {}

    -- Setup render-markdown after markdown.nvim is loaded
    require('render-markdown').setup {
      latex = {
        enabled = true,
        render_modes = true,
        converter = { 'latex2text' },
        highlight = 'RenderMarkdownMath',
        position = 'center', -- above / below / center
        top_pad = 0,
        bottom_pad = 0,
      },
      completions = {
        lsp = { enabled = true },
      },
    }
  end,
})
