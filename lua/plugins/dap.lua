-- DAP setup (deferred until after startup; only needed when debugging)
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
      sections = { 'watches', 'scopes', 'exceptions', 'breakpoints', 'threads', 'repl' },
    },
    windows = {
      position = 'right',
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
    local candidates = {
      '.venv/bin/python',
      'venv/bin/python',
      '.venv/Scripts/python.exe',
      'venv/Scripts/python.exe',
    }
    for _, rel in ipairs(candidates) do
      local path = vim.fn.getcwd() .. '/' .. rel
      if vim.fn.executable(path) == 1 then return path end
    end
    return 'python'
  end

  require('dap-python').setup(resolve_python())

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
        toggle_filebrowser = '<leader>df',
      },
    },
  }

  -- nvim-dap-matlab's <leader>dw / <leader>df send evalRequest to the MATLAB LS
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

  -- ======================
  -- MATLAB help (visual/normal mode)
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
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'nx', false)
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
    matlab_adapter.send_to_lsp_direct(cmd)

    -- poll until the engine has WRITTEN the content: fopen() creates an empty
    -- file first, so "file exists" alone returns too early
    local ok = vim.wait(
      2500,
      function() return vim.fn.filereadable(tmp) == 1 and #vim.fn.readfile(tmp) > 0 end,
      20
    )
    if not ok then
      if vim.fn.filereadable(tmp) == 1 then vim.fn.delete(tmp) end
      vim.notify('[matlab-dap] Timed out fetching help for ' .. fcn, vim.log.levels.ERROR)
      return
    end

    local contents = vim.fn.readfile(tmp)
    vim.fn.delete(tmp)
    vim.list_extend(contents, { '', '-- help(' .. fcn .. ')' })

    -- 'text' ft on purpose: a 'matlab' ft would re-fire FileType autocmds
    -- (this augroup + conform) inside the float buffer.
    vim.lsp.util.open_floating_preview(contents, 'text', { border = 'rounded' })
  end

  local function matlab_help_browser(fcn) matlab_adapter.send_to_lsp_direct("doc('" .. fcn .. "')") end

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

  local matlab_help_augroup = vim.api.nvim_create_augroup('matlab-dap-help', { clear = true })
  vim.api.nvim_create_autocmd('FileType', {
    group = matlab_help_augroup,
    pattern = 'matlab',
    callback = function(args) set_matlab_help_keymaps(args.buf) end,
  })
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(bufnr) and vim.bo[bufnr].filetype == 'matlab' then
      set_matlab_help_keymaps(bufnr)
    end
  end

  -- ======================
  -- DAP Keymaps
  -- ======================

  -- Breakpoints
  vim.keymap.set('n', '<leader>db', dap.toggle_breakpoint, {
    desc = 'Toggle breakpoint',
  })

  vim.keymap.set(
    'n',
    '<leader>dB',
    function() dap.set_breakpoint(vim.fn.input 'Breakpoint condition: ') end,
    {
      desc = 'Conditional breakpoint',
    }
  )

  vim.keymap.set(
    'n',
    '<leader>dL',
    function() dap.set_breakpoint(nil, nil, vim.fn.input 'Log message: ') end,
    {
      desc = 'Log breakpoint',
    }
  )

  vim.keymap.set('n', '<leader>dl', dap.list_breakpoints, {
    desc = 'List breakpoints',
  })

  vim.keymap.set('n', '<leader>dX', dap.clear_breakpoints, {
    desc = 'Clear all breakpoints',
  })

  -- Execution
  vim.keymap.set('n', '<F5>', dap.continue, {
    desc = 'Continue / Start',
  })

  vim.keymap.set('n', '<leader>dg', dap.continue, {
    desc = 'Go',
  })

  vim.keymap.set('n', '<leader>dR', dap.run_last, {
    desc = 'Run last debug session',
  })

  vim.keymap.set('n', '<leader>dP', dap.pause, {
    desc = 'Pause',
  })

  vim.keymap.set('n', '<leader>dt', dap.terminate, {
    desc = 'Terminate',
  })

  vim.keymap.set('n', '<leader>dq', dap.disconnect, {
    desc = 'Disconnect',
  })

  vim.keymap.set('n', '<leader>dC', dap.run_to_cursor, {
    desc = 'Run to cursor',
  })

  -- Stepping
  vim.keymap.set('n', '<leader>do', dap.step_over, {
    desc = 'Step over',
  })

  vim.keymap.set('n', '<leader>di', dap.step_into, {
    desc = 'Step into',
  })

  vim.keymap.set('n', '<leader>dO', dap.step_out, {
    desc = 'Step out',
  })

  vim.keymap.set('n', '<leader>dF', dap.restart_frame, {
    desc = 'Restart frame',
  })

  -- Inspection
  vim.keymap.set('n', '<leader>de', function() dap_view.hover() end, {
    desc = 'Evaluate / hover expression',
  })

  vim.keymap.set('n', '<leader>dv', function() dap_view.hover() end, {
    desc = 'Hover variable',
  })

  vim.keymap.set('n', '<leader>dW', function() dap_view.add_expr() end, {
    desc = 'Add watch',
  })

  -- UI
  vim.keymap.set('n', '<leader>du', function() dap_view.toggle() end, {
    desc = 'Toggle DAP View',
  })

  vim.keymap.set('n', '<leader>dr', function() dap_view.show_view 'repl' end, {
    desc = 'Switch to REPL view',
  })

  vim.keymap.set('n', '<leader>ds', function() dap_view.show_view 'scopes' end, {
    desc = 'Switch to Scopes view',
  })

  vim.keymap.set('n', '<leader>dn', function() dap_view.show_view 'breakpoints' end, {
    desc = 'Switch to Breakpoints view',
  })

  vim.keymap.set('n', '<leader>dS', function() dap_view.show_view 'threads' end, {
    desc = 'Switch to Threads view',
  })

  vim.keymap.set('n', '<leader>dh', function() dap_view.jump_to_view 'threads' end, {
    desc = 'Focus threads (stack frames)',
  })

  -- Stack navigation
  vim.keymap.set('n', '<leader>dk', dap.up, {
    desc = 'Move up stack frame',
  })

  vim.keymap.set('n', '<leader>dj', dap.down, {
    desc = 'Move down stack frame',
  })

  -- Visual / operator-pending evaluation
  vim.keymap.set({ 'x', 'o' }, '<leader>de', function() dap_view.hover() end, {
    desc = 'Evaluate / hover selection',
  })
end)
