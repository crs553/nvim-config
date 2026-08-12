-- DAP setup (deferred until after startup; only needed when debugging)
require('config.lazy').setup(function()
  local dap = require 'dap'
  local dapui = require 'dapui'

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
  -- DAP UI Setup
  -- ======================
  dapui.setup {
    icons = { expanded = '▾', collapsed = '▸', current_frame = '▸' },
    controls = {
      icons = {
        pause = '⏸',
        play = '▶',
        step_into = '⏎',
        step_over = '⏭',
        step_out = '⏮',
        step_back = '⏪',
        run_last = '▶▶',
        terminate = '⏹',
        disconnect = '⏏',
      },
    },
    layouts = {
      {
        elements = {
          { id = 'scopes', size = 0.35 },
          { id = 'breakpoints', size = 0.20 },
          { id = 'stacks', size = 0.25 },
          { id = 'watches', size = 0.20 },
        },
        size = 40,
        position = 'left',
      },
      {
        elements = {
          { id = 'repl', size = 1 },
        },
        size = 10,
        position = 'bottom',
      },
    },
  }

  -- Auto-open/close DAP UI
  dap.listeners.after.event_initialized['dapui'] = function() dapui.open { reset = true } end
  dap.listeners.after.event_terminated['dapui'] = function() dapui.close() end
  dap.listeners.after.event_exited['dapui'] = function() dapui.close() end

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
  -- Virtual Text
  -- ======================
  require('nvim-dap-virtual-text').setup {
    enabled = true,
    virt_text_pos = 'eol',
    highlight_changed_variables = true,
    show_stop_reason = true,
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
  require('dap-python').setup 'python'
  -- Resolve python from virtualenvs
  _G._python_dap = function()
    local venv_paths = {
      vim.fn.getcwd() .. '/.venv/bin/python',
      vim.fn.getcwd() .. '/venv/bin/python',
      vim.fn.getcwd() .. '/.venv/Scripts/python.exe',
      vim.fn.getcwd() .. '/venv/Scripts/python.exe',
    }
    for _, path in ipairs(venv_paths) do
      if vim.fn.executable(path) == 1 then return path end
    end
    return 'python'
  end
  vim.cmd [[command! -nargs=* DapPythonSetPython lua require("dap-python").setup(_G._python_dap())]]
  vim.cmd [[DapPythonSetPython]]

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
  vim.keymap.set('n', '<leader>de', function() dapui.eval() end, {
    desc = 'Evaluate expression',
  })

  vim.keymap.set('n', '<leader>dv', function() require('dap.ui.widgets').hover() end, {
    desc = 'Hover variable',
  })

  vim.keymap.set('n', '<leader>dW', function() dapui.elements.watches.add() end, {
    desc = 'Add watch',
  })

  -- UI
  vim.keymap.set('n', '<leader>du', dapui.toggle, {
    desc = 'Toggle DAP UI',
  })

  vim.keymap.set('n', '<leader>dr', function() dap.repl.toggle({}, 'vsplit') end, {
    desc = 'Toggle REPL',
  })

  vim.keymap.set('n', '<leader>dh', function()
    local buf = dapui.elements.stacks.buffer()
    local wins = vim.fn.win_findbuf(buf)

    if #wins > 0 then vim.api.nvim_set_current_win(wins[1]) end
  end, {
    desc = 'Focus stacks',
  })

  -- Stack navigation
  vim.keymap.set('n', '<leader>dk', dap.up, {
    desc = 'Move up stack frame',
  })

  vim.keymap.set('n', '<leader>dj', dap.down, {
    desc = 'Move down stack frame',
  })

  -- Visual / operator-pending evaluation
  vim.keymap.set({ 'x', 'o' }, '<leader>de', function() dapui.eval() end, {
    desc = 'Evaluate expression',
  })
end)
