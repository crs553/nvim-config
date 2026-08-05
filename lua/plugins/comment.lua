-- mini.comment (deferred until after startup)
require('config.lazy').setup(function()
  require('mini.comment').setup {}

  local map = vim.keymap.set
  map('n', '<leader>cc', 'gcc', { desc = 'Toggle comment (line)' })
  map({ 'n', 'x', 'o' }, '<leader>cc', 'gc', { desc = 'Toggle comment' })
end)
