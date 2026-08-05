local wk = require 'which-key'
wk.setup {}

vim.keymap.set(
  'n',
  '<leader>?',
  function() wk.show { global = false } end,
  { desc = 'Buffer Local Keymaps (which-key)' }
)

-- add groups
wk.add {
  { '<leader>a', group = 'AI' },
  { '<leader>ac', group = 'CLI' },
  { '<leader>b', group = 'Buffers' },
  { '<leader>c', group = 'Comment' },
  { '<leader>d', group = 'DAP' },
  { '<leader>f', group = 'Find...' },
  { '<leader>fi', group = 'Find In ...' },
  { '<leader>g', group = 'Git' },
  { '<leader>l', group = 'LSP' },
  { '<leader>m', group = 'MATLAB' },
  { '<leader>o', group = 'Obsidian' },
  { '<leader>q', group = 'Quickfix' },
  { '<leader>s', group = 'Search In ...' },
  { '<leader>u', group = 'Toggle / Undo / Notify' },
  { '<leader>v', group = 'Vim Pack ...' },
  { '<leader>x', group = 'Run...' },
  { '<leader><leader>', group = 'Source...' },
}
