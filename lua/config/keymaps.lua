-- lua/config/keymaps.lua
local map = vim.keymap.set

-- Quickfix
map('n', '<leader>qo', '<cmd>copen<CR>', { desc = 'Quickfix open' })
map('n', '<leader>qq', '<cmd>cclose<CR>', { desc = 'Quickfix quit' })
map('n', '<leader>qn', '<cmd>cnext<CR>', { desc = 'Quickfix next' })
map('n', '<leader>qp', '<cmd>cprev<CR>', { desc = 'Quickfix prev' })
map('n', '<leader>qc', function()
  vim.fn.setqflist {}
  vim.cmd 'cclose'
  vim.notify 'Quickfix list cleared'
end, { desc = 'Clear quickfix list' })
map('n', '<leader>qd', vim.diagnostic.setloclist, { desc = 'Diagnostics to loclist' })

map('n', '<space><space>x', '<cmd>source %<CR>', { desc = 'Source File' })
map('n', '<space>x', ':.lua<CR>', { desc = 'Run Line' })
map({ 'x', 'o' }, '<space>x', ':lua<CR>', { desc = 'Run Selection' })

local function close_all_buffers_except_current()
  local bufs = vim.api.nvim_list_bufs()
  local current_buf = vim.api.nvim_get_current_buf()
  for _, buf in ipairs(bufs) do
    if
      buf ~= current_buf
      and vim.api.nvim_buf_is_valid(buf)
      and vim.bo[buf].buftype ~= 'terminal'
    then
      vim.api.nvim_buf_delete(buf, { force = false })
    end
  end
  vim.notify 'Non-focused buffers deleted'
end
map('n', '<leader>bo', close_all_buffers_except_current, { desc = 'Close all other buffers' })

map('n', '<c-k>', ':wincmd k<CR>', { desc = 'Move up in split', silent = true })
map('n', '<c-j>', ':wincmd j<CR>', { desc = 'Move down in split ', silent = true })
map('n', '<c-h>', ':wincmd h<CR>', { desc = 'Move left in split', silent = true })
map('n', '<c-l>', ':wincmd l<CR>', { desc = 'Move right in split', silent = true })

map('n', '<leader>w', '<cmd>write<CR>', { desc = 'Save file' })
map('n', '<leader>e', '<cmd>Oil<CR>', { desc = 'File Explorer' })

map('n', '<Esc>', '<cmd>nohlsearch<CR>', { desc = 'Clear search highlights', nowait = true })

-- COPY/PASTE KEYMAPS --
map('n', '<leader>Y', function()
  local view = vim.fn.winsaveview()
  vim.cmd 'keepjumps keepmarks normal! ggVG"+y'
  vim.fn.winrestview(view)
end, {
  desc = 'Yank entire buffer to system clipboard',
})
map('n', '<leader>y', '"+yy', { desc = 'Yank line to system clipboard' })
map({ 'x', 'o' }, '<leader>y', '"+y', { desc = 'Yank selection to system clipboard' })
map('n', '<leader>p', '"+p', { desc = 'Paste from system clipboard' })
map({ 'x', 'o' }, '<leader>p', '"+P', { desc = 'Paste from system clipboard, replace selection' })

-- VISUAL MODE - SELECTION MANIPULATION --
map({ 'x', 'o' }, 'J', ":move '>+1<CR>gv=gv", { desc = 'Move selection down' })
map({ 'x', 'o' }, 'K', ":move '<-2<CR>gv=gv", { desc = 'Move selection up' })

-- Visual mode: indent/unindent selection and keep selection active
map({ 'x', 'o' }, '<Tab>', '>gv', { desc = 'Indent selection' })
map({ 'x', 'o' }, '<S-Tab>', '<gv', { desc = 'unindent selection' })

-- capitalise
map('n', '<M-u>', 'gUiww', { desc = 'Capitalise the inner word' })
map('n', '<M-l>', 'guiww', { desc = 'Decapitalise the inner word' })

-- Change buffer using leader keys
map('n', '<leader>bn', ':bnext<CR>', { desc = 'Next buffer' })
map('n', '<leader>bp', ':bprevious<CR>', { desc = 'Previous buffer' })
