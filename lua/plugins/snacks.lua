local S = require 'snacks'
S.setup {
  bigfile = { enabled = true },
  image = { enabled = true },
  indent = { enabled = true },
  input = { enabled = true },
  notifier = { enabled = false },
  picker = {
    enabled = true,
    -- Telescope-style prompt icon
    prompt = '    ',
    layouts = {
      -- Telescope `flex` (horizontal): prompt top, preview on the right
      default = {
        layout = {
          backdrop = false,
          box = 'horizontal',
          width = 0.9,
          min_width = 120,
          height = 0.85,
          {
            box = 'vertical',
            border = true,
            title = '{title} {live} {flags}',
            { win = 'input', height = 1, border = 'bottom' },
            { win = 'list', border = 'none' },
          },
          { win = 'preview', title = '{preview}', border = true, width = 0.55 },
        },
      },
      -- Telescope `flex` (vertical): prompt top, preview at the bottom
      vertical = {
        layout = {
          backdrop = false,
          width = 0.9,
          min_width = 80,
          height = 0.9,
          min_height = 30,
          box = 'vertical',
          border = true,
          title = '{title} {live} {flags}',
          title_pos = 'center',
          { win = 'input', height = 1, border = 'bottom' },
          { win = 'list', border = 'none' },
          { win = 'preview', title = '{preview}', height = 0.55, border = 'top' },
        },
      },
      -- Telescope file pickers: centered box, preview at the bottom
      telescope = {
        layout = {
          backdrop = false,
          width = 0.75,
          min_width = 80,
          height = 0.75,
          min_height = 30,
          box = 'vertical',
          border = true,
          title = '{title} {live} {flags}',
          title_pos = 'center',
          { win = 'input', height = 1, border = 'bottom' },
          { win = 'list', border = 'none' },
          { win = 'preview', title = '{preview}', height = 0.45, border = 'top' },
        },
      },
    },
    sources = {
      files = {
        hidden = true,
        follow = true,
        exclude = { 'node_modules', 'dist', 'build', '__pycache__' },
        layout = { preset = 'telescope' },
      },
      git_files = {
        layout = { preset = 'telescope' },
      },
      command_history = {
        layout = { preset = 'telescope' },
      },
      grep = {
        hidden = true,
        exclude = { 'node_modules', 'dist', 'build', '__pycache__' },
        layout = 'ivy',
      },
      grep_buffers = {
        layout = 'ivy',
      },
      lines = {
        layout = 'ivy',
      },
      help = {
        layout = 'ivy',
      },
      buffers = {
        layout = { preset = 'ivy', layout = { height = 0.33 } },
      },
    },
  },
  quickfile = { enabled = true },
  scope = { enabled = true },
  scroll = { enabled = true },
  statuscolumn = { enabled = true },
  words = { enabled = true },
  styles = { notification = { wo = { wrap = true } } },
}

-- Keymaps
local map = vim.keymap

-- Other
map.set('n', '<leader>.', function() S.scratch() end, { desc = 'Toggle Scratch Buffer' })
map.set('n', '<leader>S', function() S.scratch.select() end, { desc = 'Select Scratch Buffer' })
map.set('n', '<leader>bd', function() S.bufdelete() end, { desc = 'Delete Buffer' })
map.set('n', '<leader>br', function() S.rename.rename_file() end, { desc = 'Rename File' })
map.set({ 'n', 'x', 'o' }, '<leader>gB', function() S.gitbrowse() end, { desc = 'Git Browse' })

map.set('n', '<c-_>', function() S.terminal() end, { desc = 'which_key_ignore' })
map.set({ 'n', 't' }, ']]', function() S.words.jump(vim.v.count1) end, { desc = 'Next Reference' })
map.set({ 'n', 't' }, '[[', function() S.words.jump(-vim.v.count1) end, { desc = 'Prev Reference' })
map.set(
  'n',
  '<leader>N',
  function()
    S.win {
      file = vim.api.nvim_get_runtime_file('doc/news.txt', false)[1],
      width = 0.6,
      height = 0.6,
      wo = { spell = false, wrap = false, signcolumn = 'yes', statuscolumn = ' ', conceallevel = 3 },
    }
  end,
  { desc = 'Neovim News' }
)

-- Init / Lazy setup
vim.api.nvim_create_autocmd('User', {
  pattern = 'VeryLazy',
  callback = function()
    _G.dd = function(...) S.debug.inspect(...) end
    _G.bt = function() S.debug.backtrace() end
    vim.print = _G.dd

    -- Toggle mappings
    S.toggle.option('spell', { name = 'Spelling' }):map '<leader>us'
    S.toggle.option('wrap', { name = 'Wrap' }):map '<leader>uw'
    S.toggle.option('relativenumber', { name = 'Relative Number' }):map '<leader>uL'
    S.toggle.diagnostics():map '<leader>ud'
    S.toggle.line_number():map '<leader>ul'
    S.toggle
      .option('conceallevel', { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 })
      :map '<leader>uc'
    S.toggle.treesitter():map '<leader>uT'
    S.toggle
      .option('background', { off = 'light', on = 'dark', name = 'Dark Background' })
      :map '<leader>ub'
    S.toggle.inlay_hints():map '<leader>uh'
    S.toggle.indent():map '<leader>ug'
    S.toggle.dim():map '<leader>uD'
  end,
})
