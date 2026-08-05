local S = require 'snacks'
local map = vim.keymap.set

local function config_dir() return vim.fn.stdpath 'config' end

-- pickers auto-load `snacks.picker` on first use via `S.picker.<source>`

-- Command history
map('n', '<leader>:', function() S.picker.command_history() end, { desc = 'Command History' })

-- Notifications (no picker equivalent -> use messages)
map('n', '<leader>fn', function() vim.cmd 'messages' end, { desc = 'Find Notification History' })

-- Buffers
map(
  'n',
  '<leader>fb',
  function() S.picker.buffers { layout = 'ivy' } end,
  { desc = 'Find Buffers' }
)
map('n', '<leader>fib', function() S.picker.lines() end, { desc = 'Find In Buffer' })
map('n', '<leader>fiB', function() S.picker.grep_buffers() end, { desc = 'Find In Buffers' })

-- Files
map(
  'n',
  '<leader>fc',
  function() S.picker.files { cwd = config_dir(), ignored = true } end,
  { desc = 'Find Config File' }
)
map('n', '<leader>fd', function() S.picker.files { ignored = true } end, { desc = 'Find Files' })
map('n', '<leader>fg', function() S.picker.git_files() end, { desc = 'Find Git Files' })
map('n', '<leader>fp', function() S.picker.projects() end, { desc = 'Switch project root' })
map('n', '<leader>fr', function() S.picker.recent() end, { desc = 'Recent Files' })

-- Grep
map('n', '<leader>fs', function() S.picker.grep() end, { desc = 'Grep' })

-- Help
map('n', '<leader>fh', function() S.picker.help { layout = 'ivy' } end, { desc = 'Help Pages' })

-- Keymaps
map('n', '<leader>fk', function() S.picker.keymaps() end, { desc = 'Search Keymaps' })

-- Colorscheme (live preview built-in)
map('n', '<leader>fz', function() S.picker.colorschemes() end, { desc = 'Colorscheme picker' })

-- Git
map('n', '<leader>gb', function() S.picker.git_branches() end, { desc = 'Git Branches' })
map('n', '<leader>gl', function() S.picker.git_log() end, { desc = 'Git Log' })
map('n', '<leader>gL', function() S.picker.git_log_line() end, { desc = 'Git Log Line' })
map('n', '<leader>gs', function() S.picker.git_status() end, { desc = 'Git Status' })
map('n', '<leader>gS', function() S.picker.git_stash() end, { desc = 'Git Stash' })
map('n', '<leader>gd', function() S.picker.git_log_file() end, { desc = 'Git Log File' })
map('n', '<leader>gf', function() S.picker.git_log_file() end, { desc = 'Git Log File' })

-- Search
map('n', '<leader>sb', function() S.picker.lines() end, { desc = 'Buffer Lines' })
map('n', '<leader>sB', function() S.picker.grep_buffers() end, { desc = 'Grep Open Buffers' })
map(
  { 'n', 'x' },
  '<leader>sw',
  function() S.picker.grep_word() end,
  { desc = 'Visual selection or word' }
)
map('n', '<leader>s"', function() S.picker.registers() end, { desc = 'Registers' })
map('n', '<leader>s/', function() S.picker.search_history() end, { desc = 'Search History' })
map('n', '<leader>sa', function() S.picker.autocmds() end, { desc = 'Find Autocmds' })

-- LSP (pick on LSP clients, fall back to plain vim.lsp when none)
local function lsp_pick(pick, fallback)
  return function()
    if vim.lsp.get_clients({ bufnr = 0 })[1] then
      pick()
    else
      fallback()
    end
  end
end

map(
  'n',
  'grd',
  lsp_pick(S.picker.lsp_definitions, vim.lsp.buf.definition),
  { desc = 'Goto Definition' }
)
map(
  'n',
  'grD',
  lsp_pick(S.picker.lsp_declarations, vim.lsp.buf.declaration),
  { desc = 'Goto Declaration' }
)
map(
  'n',
  'gri',
  lsp_pick(S.picker.lsp_implementations, vim.lsp.buf.implementation),
  { desc = 'Goto Implementation' }
)
map(
  'n',
  'gry',
  lsp_pick(S.picker.lsp_type_definitions, vim.lsp.buf.type_definition),
  { desc = 'Goto Type Definition' }
)
map(
  'n',
  'grx',
  lsp_pick(S.picker.lsp_references, vim.lsp.buf.references),
  { desc = 'References', nowait = true }
)
map({ 'n', 'v' }, '<leader>le', function() S.picker.diagnostics() end, { desc = 'All Diagnostics' })
