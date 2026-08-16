-- State tables
local lazygit_state = { buf = nil, win = nil, is_open = false }
local shell_state = { buf = nil, win = nil, is_open = false }

-- Create autocommand group
local augroup = vim.api.nvim_create_augroup('FloatTerminal', { clear = true })

-- Shared floating window helper
local function create_floating_win(buf)
  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.8)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    row = row,
    col = col,
    style = 'minimal',
    border = 'rounded',
  })

  vim.wo[win].winblend = 0
  vim.wo[win].winhighlight = 'Normal:FloatingTermNormal,FloatBorder:FloatingTermBorder'
  vim.api.nvim_set_hl(0, 'FloatingTermNormal', { bg = 'none' })
  vim.api.nvim_set_hl(0, 'FloatingTermBorder', { bg = 'none' })

  return win
end

-- TermOpen styling
vim.api.nvim_create_autocmd('TermOpen', {
  group = augroup,
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.signcolumn = 'no'
  end,
})

-- LazyGit Floating Terminal
local function FloatingLazyGit()
  -- Toggle if already open
  if
    lazygit_state.is_open
    and lazygit_state.win
    and vim.api.nvim_win_is_valid(lazygit_state.win)
  then
    vim.api.nvim_win_close(lazygit_state.win, false)
    lazygit_state.is_open = false
    return
  end

  -- Create buffer
  lazygit_state.buf = vim.api.nvim_create_buf(false, true)
  vim.bo[lazygit_state.buf].bufhidden = 'hide'

  -- Floating window dimensions
  lazygit_state.win = create_floating_win(lazygit_state.buf)

  -- Launch lazygit and clean up on exit
  vim.fn.jobstart({ 'lazygit' }, {
    term = true,
    on_exit = function(_, _)
      if lazygit_state.win and vim.api.nvim_win_is_valid(lazygit_state.win) then
        vim.api.nvim_win_close(lazygit_state.win, false)
      end
      if lazygit_state.buf and vim.api.nvim_buf_is_valid(lazygit_state.buf) then
        vim.api.nvim_buf_delete(lazygit_state.buf, { force = true })
      end

      lazygit_state.buf = nil
      lazygit_state.win = nil
      lazygit_state.is_open = false
    end,
  })

  lazygit_state.is_open = true
  vim.cmd 'startinsert'
end

-- Keymap for lazygit
vim.keymap.set('n', '<leader>gg', FloatingLazyGit, {
  noremap = true,
  silent = true,
  desc = 'Open lazygit in floating terminal',
})

-- Normal Floating Terminal
local function FloatingTerminal()
  -- Toggle if already open
  if shell_state.is_open and shell_state.win and vim.api.nvim_win_is_valid(shell_state.win) then
    vim.api.nvim_win_close(shell_state.win, false)
    shell_state.is_open = false
    return
  end

  -- Reuse buffer if it exists
  if not shell_state.buf or not vim.api.nvim_buf_is_valid(shell_state.buf) then
    shell_state.buf = vim.api.nvim_create_buf(false, true)
    vim.bo[shell_state.buf].bufhidden = 'hide'
  end

  -- Create floating window
  shell_state.win = create_floating_win(shell_state.buf)

  -- Check if a terminal is already attached
  local has_terminal = vim.bo[shell_state.buf].buftype == 'terminal'

  if not has_terminal then
    -- Attach the terminal to the floating buffer
    vim.api.nvim_set_current_win(shell_state.win)

    local shell
    if vim.fn.has 'win32' == 1 then
      -- Prefer PowerShell on Windows
      shell = { 'powershell.exe' }
      -- Or use PowerShell 7 if you prefer:
      -- shell = { "pwsh.exe" }
    else
      shell = { vim.o.shell }
    end

    vim.fn.jobstart(shell, {
      term = true,
    })
  end

  shell_state.is_open = true
  vim.cmd 'startinsert'
end -- Keymaps for normal terminal
vim.keymap.set('n', '<M-i>', FloatingTerminal, {
  noremap = true,
  silent = true,
  desc = 'Toggle floating shell terminal',
})
vim.keymap.set('t', '<M-i>', function()
  if shell_state.is_open and shell_state.win and vim.api.nvim_win_is_valid(shell_state.win) then
    vim.api.nvim_win_close(shell_state.win, false)
    shell_state.is_open = false
  end
end, {
  noremap = true,
  silent = true,
  desc = 'Toggle floating shell terminal',
})

-- Persistent split terminal (reopened when hidden to background)
local splitterm_state = { buf = nil, win = nil }

local function start_terminal_in_current_win()
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = 'hide'
  vim.api.nvim_win_set_buf(vim.api.nvim_get_current_win(), buf)

  local shell
  if vim.fn.has 'win32' == 1 then
    shell = { 'powershell.exe' }
  else
    shell = { vim.o.shell }
  end

  vim.fn.jobstart(shell, {
    term = true,
    on_exit = function()
      if splitterm_state.buf == buf then splitterm_state.buf = nil end
      splitterm_state.win = nil
    end,
  })
  return buf
end

local function open_split_terminal(open)
  if
    splitterm_state.win
    and vim.api.nvim_win_is_valid(splitterm_state.win)
    and vim.bo[vim.api.nvim_win_get_buf(splitterm_state.win)].buftype == 'terminal'
  then
    vim.api.nvim_set_current_win(splitterm_state.win)
    vim.cmd 'startinsert'
    return
  end

  if open == 'split' then
    vim.cmd 'split'
  elseif open == 'left' then
    vim.cmd 'vsplit'
    vim.cmd 'wincmd h'
  else
    vim.cmd 'vsplit'
  end

  if splitterm_state.buf and vim.api.nvim_buf_is_valid(splitterm_state.buf) then
    vim.api.nvim_win_set_buf(vim.api.nvim_get_current_win(), splitterm_state.buf)
  else
    splitterm_state.buf = start_terminal_in_current_win()
  end
  splitterm_state.win = vim.api.nvim_get_current_win()
  vim.cmd 'startinsert'
end

-- Vertical split terminal (default right)
vim.api.nvim_create_user_command(
  'Termvsplit',
  function(opts) open_split_terminal(opts.fargs[1] == 'left' and 'left' or 'vsplit') end,
  {
    nargs = '?',
    complete = function() return { 'left', 'right' } end,
  }
)
vim.cmd.cabbrev('termvsplit', 'Termvsplit')

vim.keymap.set('n', '<leader>tv', function() vim.cmd 'Termvsplit' end, {
  noremap = true,
  silent = true,
  desc = 'Open terminal in vertical split',
})
vim.keymap.set('n', '<leader>th', function() open_split_terminal 'split' end, {
  noremap = true,
  silent = true,
  desc = 'Open terminal in horizontal split',
})

-- Close terminal window, keep shell running in the background
vim.keymap.set('t', '<M-x>', '<C-\\><C-n>:close<CR>', {
  desc = 'Close terminal split (keep shell running in background)',
})
