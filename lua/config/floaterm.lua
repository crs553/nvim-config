-- State tables
local lazygit_state = { buf = nil, win = nil, is_open = false }
local shell_state = { buf = nil, win = nil, is_open = false }

-- Create autocommand group
local augroup = vim.api.nvim_create_augroup('FloatTerminal', { clear = true })

---Return the appropriate shell command for the current platform.
---@return string[]
local function get_shell()
  if vim.fn.has 'win32' == 1 then return { 'powershell.exe' } end
  return { vim.o.shell }
end

-- Highlight groups (defined once at module load)
vim.api.nvim_set_hl(0, 'FloatingTermNormal', { bg = 'none' })
vim.api.nvim_set_hl(0, 'FloatingTermBorder', { bg = 'none' })

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
    vim.fn.jobstart(get_shell(), { term = true })
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

-- Persistent split terminals (one per orientation, reopened when hidden)
local splitterm_state = {
  v = { buf = nil, win = nil },
  h = { buf = nil, win = nil },
}
local esc_double_timeout = 500
local open_split_terminal

local function term_win_open(state)
  return state.win
    and vim.api.nvim_win_is_valid(state.win)
    and vim.bo[vim.api.nvim_win_get_buf(state.win)].buftype == 'terminal'
end

local function close_split_terminal(state)
  if term_win_open(state) then pcall(vim.api.nvim_win_close, state.win, false) end
  state.win = nil
end

local function attach_split_term_maps(buf)
  -- Esc leaves terminal mode; a second Esc within the timeout closes the split
  vim.keymap.set('t', '<Esc>', function()
    vim.b[buf].split_term_esc_at = vim.uv.now()
    vim.api.nvim_feedkeys(
      vim.api.nvim_replace_termcodes('<C-\\><C-n>', true, false, true),
      'n',
      false
    )
  end, { buffer = buf, desc = 'Leave terminal mode' })

  vim.keymap.set('n', '<Esc>', function()
    local now = vim.uv.now()
    local last = vim.b[buf].split_term_esc_at or 0

    if now - last <= esc_double_timeout then
      vim.b[buf].split_term_esc_at = 0
      for _, state in pairs(splitterm_state) do
        if state.buf == buf then state.win = nil end
      end
      pcall(vim.api.nvim_win_close, vim.api.nvim_get_current_win(), false)
    else
      vim.b[buf].split_term_esc_at = now
      vim.cmd 'nohlsearch'
    end
  end, { buffer = buf, nowait = true, desc = 'Double Esc to close terminal' })

  -- Repressing the toggle key while inside the terminal closes its split
  vim.keymap.set('t', '<M-v>', function() open_split_terminal 'vsplit' end, {
    buffer = buf,
    desc = 'Toggle vertical terminal split',
  })
  vim.keymap.set('t', '<M-h>', function() open_split_terminal 'split' end, {
    buffer = buf,
    desc = 'Toggle horizontal terminal split',
  })
end

local function start_terminal_in_current_win(state)
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = 'hide'
  vim.api.nvim_win_set_buf(vim.api.nvim_get_current_win(), buf)

  vim.fn.jobstart(get_shell(), {
    term = true,
    on_exit = function()
      if state.buf ~= buf then return end
      state.buf = nil
      if state.win and vim.api.nvim_win_is_valid(state.win) then
        pcall(vim.api.nvim_win_close, state.win, false)
      end
      state.win = nil
    end,
  })

  attach_split_term_maps(buf)
  return buf
end

function open_split_terminal(open)
  local axis = open == 'split' and 'h' or 'v'
  local state = splitterm_state[axis]

  if term_win_open(state) then
    if vim.api.nvim_get_current_win() == state.win then
      close_split_terminal(state)
      return
    end
    vim.api.nvim_set_current_win(state.win)
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

  if state.buf and vim.api.nvim_buf_is_valid(state.buf) then
    vim.api.nvim_win_set_buf(vim.api.nvim_get_current_win(), state.buf)
  else
    state.buf = start_terminal_in_current_win(state)
  end
  state.win = vim.api.nvim_get_current_win()
  vim.cmd 'startinsert'
end

-- Keep state in sync when a split is closed manually or via <M-x>
vim.api.nvim_create_autocmd('WinClosed', {
  group = augroup,
  callback = function(args)
    local win = tonumber(args.match)
    for _, state in pairs(splitterm_state) do
      if state.win == win then state.win = nil end
    end
  end,
})

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

vim.keymap.set('n', '<M-v>', function() open_split_terminal 'vsplit' end, {
  noremap = true,
  silent = true,
  desc = 'Toggle terminal in vertical split',
})
vim.keymap.set('n', '<M-h>', function() open_split_terminal 'split' end, {
  noremap = true,
  silent = true,
  desc = 'Toggle terminal in horizontal split',
})

-- Close terminal window, keep shell running in the background
vim.keymap.set({ 't', 'n' }, '<M-x>', '<C-\\><C-n>:close<CR>', {
  desc = 'Close terminal split (keep shell running in background)',
})
