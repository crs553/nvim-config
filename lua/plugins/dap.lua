-- DAP setup.
--
-- All keymaps are registered immediately at startup (with lazy requires
-- inside the callbacks) so that an incomplete or mistimed `<leader>d`
-- sequence can never fall through to the native `d` (delete) operator.
-- Heavy setup() calls are deferred until after startup via config.lazy.

local map = vim.keymap.set

-- ======================
-- DAP Keymaps (global, registered immediately)
-- ======================

-- Guard: if a `<leader>d` sequence is left incomplete (e.g. a pause longer
-- than timeoutlen), do nothing instead of handing the remaining keys to the
-- native `d` operator.
map('n', '<leader>d', '<Nop>', { desc = 'DAP' })

-- Breakpoints
map('n', '<leader>db', function() require('dap').toggle_breakpoint() end, {
  desc = 'Toggle breakpoint',
})

map(
  'n',
  '<leader>dB',
  function() require('dap').set_breakpoint(vim.fn.input 'Breakpoint condition: ') end,
  {
    desc = 'Conditional breakpoint',
  }
)

map(
  'n',
  '<leader>dL',
  function() require('dap').set_breakpoint(nil, nil, vim.fn.input 'Log message: ') end,
  {
    desc = 'Log breakpoint',
  }
)

map('n', '<leader>dl', function() require('dap').list_breakpoints() end, {
  desc = 'List breakpoints',
})

map('n', '<leader>dX', function() require('dap').clear_breakpoints() end, {
  desc = 'Clear all breakpoints',
})

-- Execution
map('n', '<F5>', function() require('dap').continue() end, {
  desc = 'Continue / Start',
})

map('n', '<leader>dg', function() require('dap').continue() end, {
  desc = 'Continue / Start',
})

map('n', '<leader>dR', function() require('dap').run_last() end, {
  desc = 'Run last debug session',
})

map('n', '<leader>dP', function() require('dap').pause() end, {
  desc = 'Pause',
})

map('n', '<leader>dd', function() require('dap').terminate() end, {
  desc = 'Terminate',
})

map('n', '<leader>dq', function() require('dap').disconnect() end, {
  desc = 'Disconnect',
})

map('n', '<leader>dC', function() require('dap').run_to_cursor() end, {
  desc = 'Run to cursor',
})

-- Stepping
map('n', '<leader>do', function() require('dap').step_over() end, {
  desc = 'Step over',
})

map('n', '<leader>di', function() require('dap').step_into() end, {
  desc = 'Step into',
})

map('n', '<leader>dO', function() require('dap').step_out() end, {
  desc = 'Step out',
})

map('n', '<leader>dA', function() require('dap').restart_frame() end, {
  desc = 'Restart frame',
})

-- Inspection
map('n', '<leader>de', function() require('dap-view').hover() end, {
  desc = 'Evaluate / hover expression',
})

map('n', '<leader>dW', function() require('dap-view').add_expr() end, {
  desc = 'Add watch',
})

-- UI
map('n', '<leader>du', function() require('dap-view').toggle() end, {
  desc = 'Toggle DAP View',
})

map('n', '<leader>dr', function() require('dap-view').show_view 'repl' end, {
  desc = 'Switch to REPL view',
})

map('n', '<leader>ds', function() require('dap-view').show_view 'scopes' end, {
  desc = 'Switch to Scopes view',
})

map('n', '<leader>dn', function() require('dap-view').show_view 'breakpoints' end, {
  desc = 'Switch to Breakpoints view',
})

map('n', '<leader>dS', function() require('dap-view').show_view 'threads' end, {
  desc = 'Switch to Threads view',
})

map('n', '<leader>dh', function() require('dap-view').jump_to_view 'threads' end, {
  desc = 'Focus threads (stack frames)',
})

-- Stack navigation
map('n', '<leader>dk', function() require('dap').up() end, {
  desc = 'Move up stack frame',
})

map('n', '<leader>dj', function() require('dap').down() end, {
  desc = 'Move down stack frame',
})

-- Run/debug current file
map('n', '<leader>df', function()
  local dap = require 'dap'
  local ft = vim.bo.filetype
  local cfg = dap.configurations[ft]
  if cfg and #cfg > 0 then
    dap.run(cfg[1])
  else
    dap.run {
      type = ft,
      request = 'launch',
      name = 'Debug current file',
      program = '${file}',
      cwd = '${workspaceFolder}',
    }
  end
end, { desc = 'Debug/run current file' })

-- Visual / operator-pending evaluation
map({ 'x', 'o' }, '<leader>de', function() require('dap-view').hover() end, {
  desc = 'Evaluate / hover selection',
})

-- ======================
-- MATLAB help (visual/normal mode, matlab buffers)
-- ======================
-- <leader>mh : show MATLAB help("<fcn>") in a Neovim float
-- <leader>mH : open MATLAB doc("<fcn>") in the MATLAB Help browser

local function get_visual_selection()
  local srow, scol = unpack(vim.api.nvim_buf_get_mark(0, '<'))
  local erow, ecol = unpack(vim.api.nvim_buf_get_mark(0, '>'))

  if srow > erow or (srow == erow and scol > ecol) then
    srow, scol, erow, ecol = erow, ecol, srow, scol
  end

  local text =
    table.concat(vim.api.nvim_buf_get_text(0, srow - 1, scol - 1, erow - 1, ecol, {}), ' ')
  vim.api.nvim_input '<Esc>'
  return (text or ''):gsub('^%s+', ''):gsub('%s+$', '')
end

local function run_with_help_selection(fn)
  local fcn = get_visual_selection()
  if fcn == '' or not fcn:match '^[%w_.]+$' then
    vim.notify('[matlab-dap] Select a single function name first', vim.log.levels.WARN)
    return
  end
  fn(fcn)
end

-- normal-mode: use the word under the cursor, else ask in a floating input window
local function run_with_word_or_input(fn)
  local cword = vim.fn.expand '<cword>'
  if cword ~= '' and cword:match '^[%w_.]+$' then
    fn(cword)
    return
  end
  vim.ui.input({ prompt = 'MATLAB function: ' }, function(fcn)
    if not fcn or fcn == '' then return end
    fcn = fcn:gsub('^%s+', ''):gsub('%s+$', '')
    if not fcn:match '^[%w_.]+$' then
      vim.notify('[matlab-dap] Not a valid function name', vim.log.levels.WARN)
      return
    end
    fn(fcn)
  end)
end

local function matlab_help_float(fcn)
  -- evalRequest is one-way; fetch help text via a temp file round-trip.
  local tmp = vim.fn.tempname():gsub('\\', '/')
  local cmd = string.format(
    "try,f=fopen('%s','w');fprintf(f,'%%s',help('%s'));fclose(f);catch e,f=fopen('%s','w');fprintf(f,'%%s',e.message);fclose(f);end",
    tmp,
    fcn,
    tmp
  )
  require('nvim-dap-matlab.adapter').send_to_lsp_direct(cmd)

  -- poll until the engine has WRITTEN the content: fopen() creates an empty
  -- file first, so "file exists" alone returns too early. Async (defer_fn)
  -- instead of vim.wait so the UI is not blocked while waiting.
  local elapsed = 0
  local function poll()
    if vim.fn.filereadable(tmp) == 1 and #vim.fn.readfile(tmp) > 0 then
      local contents = vim.fn.readfile(tmp)
      vim.fn.delete(tmp)
      vim.list_extend(contents, { '', '-- help(' .. fcn .. ')' })

      -- 'text' ft on purpose: a 'matlab' ft would re-fire FileType autocmds
      -- (the matlab keymaps augroup + conform) inside the float buffer.
      vim.lsp.util.open_floating_preview(contents, 'text', { border = 'rounded' })
      return
    end
    elapsed = elapsed + 50
    if elapsed >= 2500 then
      if vim.fn.filereadable(tmp) == 1 then vim.fn.delete(tmp) end
      vim.notify('[matlab-dap] Timed out fetching help for ' .. fcn, vim.log.levels.ERROR)
      return
    end
    vim.defer_fn(poll, 50)
  end
  poll()
end

local function matlab_help_browser(fcn)
  require('nvim-dap-matlab.adapter').send_to_lsp_direct("doc('" .. fcn .. "')")
end

local function set_matlab_help_keymaps(bufnr)
  vim.keymap.set('n', '<leader>mh', function() run_with_word_or_input(matlab_help_float) end, {
    buffer = bufnr,
    desc = 'MATLAB: show help (float)',
  })
  vim.keymap.set('n', '<leader>mH', function() run_with_word_or_input(matlab_help_browser) end, {
    buffer = bufnr,
    desc = 'MATLAB: open in Help browser',
  })
  vim.keymap.set('x', '<leader>mh', function() run_with_help_selection(matlab_help_float) end, {
    buffer = bufnr,
    desc = 'MATLAB: show help (float)',
  })
  vim.keymap.set('x', '<leader>mH', function() run_with_help_selection(matlab_help_browser) end, {
    buffer = bufnr,
    desc = 'MATLAB: open in Help browser',
  })
end

-- ======================
-- MATLAB tests (<leader>t, matlab buffers only)
-- ======================

---Evaluate `cmd` in the REPL of an active MATLAB debug session.
---@param session table nvim-dap session
---@param cmd string MATLAB command to evaluate
---@param label string notification label
local function eval_in_matlab_repl(session, cmd, label)
  local dv_ok, dv = pcall(require, 'dap-view')
  if dv_ok then
    pcall(dv.open)
    pcall(dv.show_view, 'repl')
  end
  local repl_ok, dap_repl = pcall(require, 'dap.repl')
  if repl_ok and dap_repl.clear then pcall(dap_repl.clear) end
  vim.notify('[matlab-dap] ' .. label, vim.log.levels.INFO)
  session:evaluate(cmd, nil, { context = 'repl' })
end

local matlab_listener_seq = 0

---Run a MATLAB command, starting a MATLAB debug session first if none is
---active.
---@param cmd string MATLAB command to evaluate
---@param label string notification label
local function run_matlab_command(cmd, label)
  local dap_mod = require 'dap'
  local file = vim.fn.expand '%:p'
  local root = vim.fn.getcwd()

  local session = dap_mod.session()
  if session and session.config.type == 'matlab' then
    eval_in_matlab_repl(session, cmd, label)
    return
  end

  local ok_cfg = dap_mod.configurations.matlab and dap_mod.configurations.matlab[1]
  if not ok_cfg then
    vim.notify('[matlab-dap] No MATLAB DAP config found', vim.log.levels.ERROR)
    return
  end

  vim.notify('[matlab-dap] Starting MATLAB debug session...', vim.log.levels.INFO)
  matlab_listener_seq = matlab_listener_seq + 1
  local listener_id = 'matlab_test_' .. matlab_listener_seq
  dap_mod.listeners.after.event_initialized[listener_id] = function(s)
    if s.config.type ~= 'matlab' then return end
    dap_mod.listeners.after.event_initialized[listener_id] = nil
    vim.defer_fn(function()
      local sess = dap_mod.session()
      if sess and sess.config.type == 'matlab' then
        eval_in_matlab_repl(sess, cmd, label)
      else
        vim.notify('[matlab-dap] No active MATLAB debug session', vim.log.levels.WARN)
      end
    end, 1000)
  end
  dap_mod.run(vim.tbl_extend('force', ok_cfg, { name = 'MATLAB Test', program = file, cwd = root }))
end

local function set_matlab_test_keymaps(bufnr)
  local bmap = function(mode, keys, func, desc)
    vim.keymap.set(mode, keys, func, { buffer = bufnr, desc = desc })
  end

  bmap('n', '<leader>ta', function()
    local rel = vim.fn.fnamemodify(vim.fn.expand '%:p', ':.')
    local root = vim.fn.getcwd()

    local test_cmd = string.format(
      "clc; addpath(genpath('%s')); results = run(testsuite('%s')); disp(results);",
      root:gsub('\\', '/'),
      rel:gsub('\\', '/')
    )

    run_matlab_command(test_cmd, 'Running all tests in file...')
  end, 'MATLAB: run all tests in current file')

  bmap('n', '<leader>tf', function()
    local file = vim.fn.expand '%:p'
    local rel = vim.fn.fnamemodify(file, ':.')
    local root = vim.fn.getcwd()
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local cur = vim.api.nvim_win_get_cursor(0)[1]

    local class_name
    for _, l in ipairs(lines) do
      local m = l:match 'classdef%s+([%w_]+)'
      if m then
        class_name = m
        break
      end
    end

    local method_name
    for i = cur, 1, -1 do
      local l = lines[i]
      local m = l:match '^%s*function%s+([%w_]+)%s*%('
      if m then
        if not (m:match '^[A-Z]' and m == class_name) then
          method_name = m
          break
        end
      end
    end

    if not class_name or not method_name then
      vim.notify('[matlab-dap] Could not find test class/method under cursor', vim.log.levels.WARN)
      return
    end

    local test_cmd = string.format(
      "clc; cd('%s'); addpath(genpath('.')); suite = testsuite('%s'); "
        .. "suite = suite.selectIf('Name', '%s/%s'); "
        .. "if isempty(suite) then disp('No matching test method'); else results = run(suite); disp(results); end",
      root:gsub('\\', '/'),
      rel:gsub('\\', '/'),
      class_name,
      method_name
    )

    run_matlab_command(test_cmd, string.format('Running %s/%s...', class_name, method_name))
  end, 'MATLAB: run current test method')
end

-- ======================
-- MATLAB buffer-local keymaps (help + tests)
-- ======================

local matlab_keys_augroup = vim.api.nvim_create_augroup('matlab-dap-keys', {
  clear = true,
})
vim.api.nvim_create_autocmd('FileType', {
  group = matlab_keys_augroup,
  pattern = 'matlab',
  callback = function(args)
    set_matlab_help_keymaps(args.buf)
    set_matlab_test_keymaps(args.buf)
  end,
})
for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
  if vim.api.nvim_buf_is_valid(bufnr) and vim.bo[bufnr].filetype == 'matlab' then
    set_matlab_help_keymaps(bufnr)
    set_matlab_test_keymaps(bufnr)
  end
end

-- ======================
-- Deferred setup (heavy setup() calls, run after startup)
-- ======================
require('config.lazy').setup(function()
  local dap = require 'dap'
  local dap_view = require 'dap-view'

  -- ======================
  -- Workarounds
  -- ======================

  -- nvim-dap-matlab needs nvim-dap to send an empty `breakpoints` array when
  -- clearing breakpoints (upstream PR #1592 unmerged). Patch mainline locally
  -- so we can stay on the codeberg release.
  local dap_session = require 'dap.session'
  local orig_set_breakpoints = dap_session.set_breakpoints
  function dap_session:set_breakpoints(bps, on_done)
    if vim.tbl_count(bps) == 0 then bps = { [vim.api.nvim_get_current_buf()] = {} } end
    return orig_set_breakpoints(self, bps, on_done)
  end

  -- ======================
  -- DAP View Setup
  -- ======================
  dap_view.setup {
    winbar = {
      sections = { 'watches', 'scopes', 'exceptions', 'breakpoints', 'threads', 'repl', 'console' },
      default_section = 'repl',
    },
    auto_toggle = false,
    windows = {
      position = 'right',
      size = 0.5,
    },
    virtual_text = { enabled = true, position = 'inline' },
  }

  dap.configurations.go = {
    {
      type = 'go',
      name = 'Debug current file',
      request = 'launch',

      program = '${fileDirname}',
      cwd = '${workspaceFolder}',

      args = {},
    },
  }

  -- Wrap long lines in DAP View and REPL windows.
  local dap_wrap = vim.api.nvim_create_augroup('DapViewWrap', {
    clear = true,
  })

  vim.api.nvim_create_autocmd({ 'FileType', 'BufWinEnter', 'WinEnter' }, {
    group = dap_wrap,
    callback = function()
      local ft = vim.bo.filetype

      if ft == 'dap-view' or ft == 'dap-repl' then
        vim.wo.wrap = true
        vim.wo.linebreak = true
        vim.wo.breakindent = true
      end
    end,
  })

  -- ======================
  -- Go DAP (nvim-dap-go)
  -- ======================
  require('dap-go').setup {
    dap_configurations = {
      {
        type = 'go',
        name = 'Attach remote',
        mode = 'remote',
        request = 'attach',
      },
    },
    delve = {
      path = 'dlv',
      initialize_timeout_sec = 20,
      port = '${port}',
      args = {},
      build_flags = {},
      detached = vim.fn.has 'win32' == 0,
      cwd = nil,
    },
    tests = {
      verbose = false,
    },
  }

  -- ======================
  -- Python DAP (nvim-dap-python)
  -- ======================

  ---Resolve python from virtualenvs in the current project.
  ---@return string
  local function resolve_python()
    local cwd = vim.uv.cwd() or vim.fn.getcwd()
    local candidates = {
      vim.fs.joinpath(cwd, '.venv', 'bin', 'python'),
      vim.fs.joinpath(cwd, 'venv', 'bin', 'python'),
      vim.fs.joinpath(cwd, '.venv', 'Scripts', 'python.exe'),
      vim.fs.joinpath(cwd, 'venv', 'Scripts', 'python.exe'),
    }
    for _, path in ipairs(candidates) do
      if vim.fn.executable(path) == 1 then return path end
    end
    return 'python'
  end

  require('dap-python').setup(resolve_python())

  -- dap-python captures the interpreter path when setup() runs, so the venv
  -- resolved above would go stale after a `cwd` change. Wrap the adapter to
  -- re-resolve the project venv on every launch; include_configs = false
  -- stops setup() from duplicating its default configurations on refresh.
  local resolved_python = resolve_python()
  local python_delegate = dap.adapters.python
  local python_wrapper
  python_wrapper = function(cb, config)
    local current = resolve_python()
    if current ~= resolved_python then
      resolved_python = current
      require('dap-python').setup(current, { include_configs = false })
      python_delegate = dap.adapters.python
      dap.adapters.python = python_wrapper
      dap.adapters.debugpy = python_wrapper
    end
    python_delegate(cb, config)
  end
  dap.adapters.python = python_wrapper
  dap.adapters.debugpy = python_wrapper

  -- ======================
  -- MATLAB DAP (nvim-dap-matlab)
  -- ======================
  require('nvim-dap-matlab').setup {
    lsp_name = 'matlab_ls',
    gui_windows = {
      auto_open = {
        workspace = false,
        filebrowser = false,
      },
      keymaps = {
        toggle_workspace = '<leader>dw',
        toggle_filebrowser = '<leader>dF',
      },
    },
  }

  -- nvim-dap-matlab's <leader>dw / <leader>dF send evalRequest to the MATLAB LS
  -- as soon as `lsp_client` is set, which happens while the LS is still
  -- "connecting" (before `lsp_ready`). Same guard as adapter.start() to avoid
  -- crashing the LS during load.
  local matlab_adapter = require 'nvim-dap-matlab.adapter'
  local matlab_send_direct = matlab_adapter.send_to_lsp_direct
  matlab_adapter.send_to_lsp_direct = function(cmd)
    local st = matlab_adapter.get_state()
    if not st.lsp_client or not st.lsp_ready then
      vim.notify(
        '[matlab-dap] matlab lsp is not ready. Please wait and retry',
        vim.log.levels.ERROR
      )
      return
    end
    return matlab_send_direct(cmd)
  end
end)
