-- Native session persistence (no plugin):
--   * save  : `:mksession!` on exit, one file per working directory
--   * load  : auto-restore the session when nvim is started without file args
--   * pick  : <leader>fS to browse and source saved sessions
--
-- Session files live in stdpath('state')/sessions/.

local S = require 'snacks'

local dir = vim.fn.stdpath 'state' .. '/sessions'
vim.fn.mkdir(dir, 'p')

local function session_file()
  local name = vim.fn.getcwd():gsub('[^%w%-_.]', '_')
  return dir .. '/' .. name .. '.vim'
end

local function save_session() pcall(vim.cmd, 'mksession! ' .. vim.fn.fnameescape(session_file())) end

local function restore_session()
  if vim.fn.argc() > 0 then return end -- launched with file arguments
  local file = session_file()
  if vim.fn.filereadable(file) == 1 then vim.cmd('source ' .. vim.fn.fnameescape(file)) end
end

local group = vim.api.nvim_create_augroup('session', { clear = true })
vim.api.nvim_create_autocmd('VimLeavePre', { group = group, callback = save_session })
vim.api.nvim_create_autocmd('VimEnter', { group = group, callback = restore_session })

vim.keymap.set('n', '<leader>fS', function()
  S.picker.files {
    dirs = { dir },
    title = 'Sessions',
    actions = {
      confirm = function(picker, item)
        picker:close()
        local file = item and item.file
        if file and file ~= '' then vim.cmd('source ' .. vim.fn.fnameescape(file)) end
      end,
    },
  }
end, { desc = 'Pick Session' })
