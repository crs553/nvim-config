local hooks = function(ev)
  local name, kind = ev.data.spec.name, ev.data.kind
  if name == 'telescope-fzf-native.nvim' and (kind == 'install' or kind == 'update') then
    vim.notify('Building telescope-fzf')
    vim.system({ 'make' }, { cwd = ev.data.path }):wait()
    vim.notify('Built telescope-fzf')
  end
end
vim.api.nvim_create_autocmd('PackChanged', { callback = hooks })
pcall(require('telescope').load_extension, 'fzf')
local telescope = require('telescope')
local actions = require('telescope.actions')
local actions_layout = require('telescope.actions.layout')
local builtin = require('telescope.builtin')
local themes = require('telescope.themes')

telescope.setup {
  defaults = {
    prompt_prefix = '    ',
    selection_caret = ' ',
    entry_prefix = '  ',

    initial_mode = 'insert',
    sorting_strategy = 'ascending',
    layout_strategy = 'flex',

    path_display = { 'smart' },
    dynamic_preview_title = true,

    vimgrep_arguments = {
      'rg',
      '--color=never',
      '--no-heading',
      '--with-filename',
      '--line-number',
      '--column',
      '--smart-case',
      '--hidden',
      '--glob=!node_modules/*',
    },

    layout_config = {
      horizontal = {
        prompt_position = 'top',
        preview_width = 0.55,
        width = 0.90,
        height = 0.85,
      },
      vertical = {
        prompt_position = 'top',
        width = 0.90,
        height = 0.90,
        preview_height = 0.55,
      },
      flex = {
        flip_columns = 120,
      },
    },

    winblend = 0,

    file_ignore_patterns = {
      'node_modules',
      '.git/',
      'dist/',
      'build/',
      '__pycache__/',
    },

    borderchars = {
      '─',
      '│',
      '─',
      '│',
      '╭',
      '╮',
      '╯',
      '╰',
    },

    mappings = {
      i = {
        ['<C-j>'] = actions.move_selection_next,
        ['<C-k>'] = actions.move_selection_previous,

        ['<C-p>'] = actions_layout.toggle_preview,

        ['<C-q>'] = actions.send_to_qflist + actions.open_qflist,
        ['<Esc>'] = actions.close,
      },
      n = {
        ['<C-j>'] = actions.move_selection_next,
        ['<C-k>'] = actions.move_selection_previous,

        ['<C-q>'] = actions.send_to_qflist + actions.open_qflist,
        ['<Esc>'] = actions.close,
      },
    },
  },

  pickers = {
    find_files = {
      hidden = true,
      follow = true,
      layout_strategy = 'vertical',
      layout_config = {
        width = 0.75,
        height = 0.75,
        preview_height = 0.45,
        prompt_position = 'top',
      },
    },

    git_files = {
      show_untracked = false,
      layout_strategy = 'vertical',
      layout_config = {
        width = 0.75,
        height = 0.75,
        preview_height = 0.45,
        prompt_position = 'top',
      },
    },

    buffers = themes.get_ivy {
      previewer = false,
      sort_lastused = true,
      layout_config = {
        height = 0.33,
      },
    },

    command_history = {
      layout_strategy = 'vertical',
      layout_config = {
        width = 0.75,
        height = 0.75,
        preview_height = 0.45,
        prompt_position = 'top',
      },
    },

    help_tags = {
      layout_strategy = 'vertical',
      layout_config = {
        width = 0.75,
        height = 0.75,
        preview_height = 0.45,
        prompt_position = 'top',
      },
    },

    live_grep = {
      theme = 'ivy',
      additional_args = function()
        return { '--hidden' }
      end,
    },
  },

  extensions = {
    fzf = {
      fuzzy = true,
      override_generic_sorter = true,
      override_file_sorter = true,
      case_mode = 'smart_case',
    },
  },
}

-- helpers
local function config_dir()
  return vim.fn.stdpath('config')
end

---------------------------------------------------------------------
-- PICKERS (Snacks → Telescope equivalents)
---------------------------------------------------------------------

local map = vim.keymap.set

-- Command history
map('n', '<leader>:', builtin.command_history, { desc = 'Command History' })

-- Notifications (no native telescope equivalent → use messages)
-- TODO: write my own plugin for this?
map('n', '<leader>fn', function()
  vim.cmd('messages')
end, { desc = 'Find Notification History' })

-- Buffers
map('n', '<leader>fb', builtin.buffers, { desc = 'Find Buffers' })

map('n', '<leader>fib', function()
  builtin.current_buffer_fuzzy_find(themes.get_ivy {})
end, { desc = 'Find In Buffer' })

vim.keymap.set('n', '<leader>fiB', function()
  builtin.live_grep {
    grep_open_files = true,
    prompt_title = 'Live Grep Open Buffers',
  }
end, { desc = 'Find In Buffers' })

map('n', '<leader>fc', function()
  builtin.find_files {
    cwd = config_dir(),
    no_ignore = true,
  }
end, { desc = 'Find Config File' })

-- Files
map('n', '<leader>fd', function()
  builtin.find_files {
    no_ignore = true,
  }
end, { desc = 'Find Files' })

-- Git files
map('n', '<leader>fg', builtin.git_files, { desc = 'Find Git Files' })

-- Projects (closest equivalent: find directories via fd fallback)
map('n', '<leader>fp', function()
  local dirs = {}
  local search_dirs = {
    vim.fn.expand('~/Projects'),
    vim.fn.expand('~/.dotfiles'),
    vim.fn.expand('~/Documents/git-repos'),
  }
  for _, dir in ipairs(search_dirs) do
    local handle = vim.uv.fs_scandir(dir)
    if handle then
      while true do
        local name, type = vim.uv.fs_scandir_next(handle)
        if not name then
          break
        end
        if type == 'directory' then
          table.insert(dirs, dir .. '/' .. name)
        end
      end
    end
  end
  require('telescope.pickers')
    .new(
      {},
      themes.get_ivy {
        prompt_title = 'Projects',
        finder = require('telescope.finders').new_table { results = dirs },
        sorter = require('telescope.config').values.generic_sorter {},
        attach_mappings = function(prompt_bufnr)
          actions.select_default:replace(function()
            local entry = require('telescope.actions.state').get_selected_entry()
            actions.close(prompt_bufnr)
            if entry then
              vim.api.nvim_set_current_dir(entry.value)
            end
          end)
          return true
        end,
      }
    )
    :find()
end, { desc = 'Switch project root' })

-- Recent files
--map('n', '<leader>fr', builtin.oldfiles, { desc = 'Recent' })

-- Grep
map('n', '<leader>fs', function()
  builtin.live_grep()
end, { desc = 'Grep' })

-- Help
map('n', '<leader>fh', function()
  builtin.help_tags(themes.get_ivy {})
end, { desc = 'Help Pages' })

-- Keymaps
map('n', '<leader>fk', builtin.keymaps, { desc = 'Search Keymaps' })

--Colorscheme
map('n', '<leader>fz', function()
  local colors = vim.fn.getcompletion('', 'color')

  local ignore = {
    miniautumn = true,
    minicyan = true,
    minischeme = true,
    minispring = true,
    minisummer = true,
    miniwinter = true,
    randomhue = true,
  }

  colors = vim.tbl_filter(function(c)
    return not ignore[c]
  end, colors)

  local previewed = nil

  require('telescope.pickers')
    .new({}, {
      prompt_title = 'Colorschemes',
      finder = require('telescope.finders').new_table {
        results = colors,
      },
      sorter = require('telescope.config').values.generic_sorter {},

      attach_mappings = function(prompt_bufnr, map_fn)
        local state = require('telescope.actions.state')

        local function set_preview()
          local entry = state.get_selected_entry()
          if entry and entry.value ~= previewed then
            previewed = entry.value
            vim.cmd.colorscheme(entry.value)
          end
        end

        -- preview while moving
        map_fn('i', '<Down>', function()
          actions.move_selection_next(prompt_bufnr)
          set_preview()
        end)

        map_fn('i', '<Up>', function()
          actions.move_selection_previous(prompt_bufnr)
          set_preview()
        end)

        -- apply permanently
        actions.select_default:replace(function()
          local entry = state.get_selected_entry()
          actions.close(prompt_bufnr)
          vim.cmd.colorscheme(entry.value)
        end)

        return true
      end,
    })
    :find()
end, { desc = 'Colorscheme picker (filtered + preview)' })
---------------------------------------------------------------------
-- GIT (Telescope native equivalents)
---------------------------------------------------------------------

map('n', '<leader>gb', builtin.git_branches, { desc = 'Git Branches' })
map('n', '<leader>gl', builtin.git_commits, { desc = 'Git Log' })

map('n', '<leader>gL', function()
  builtin.git_bcommits()
end, { desc = 'Git Log Line' })

map('n', '<leader>gs', builtin.git_status, { desc = 'Git Status' })

map('n', '<leader>gS', function()
  vim.cmd('Git stash') -- fallback (Telescope doesn't have stash picker built-in)
end, { desc = 'Git Stash' })

map('n', '<leader>gd', builtin.git_bcommits, { desc = 'Git Diff (Hunks via commits)' })

map('n', '<leader>gf', function()
  builtin.git_bcommits {
    bufnr = vim.api.nvim_get_current_buf(),
  }
end, { desc = 'Git Log File' })
---------------------------------------------------------------------
-- SEARCH / GREP
---------------------------------------------------------------------

map('n', '<leader>sb', builtin.current_buffer_fuzzy_find, { desc = 'Buffer Lines' })

map('n', '<leader>sB', function()
  builtin.grep_string {
    search = '',
    grep_open_files = true,
  }
end, { desc = 'Grep Open Buffers' })

map({ 'n', 'x' }, '<leader>sw', builtin.grep_string, { desc = 'Visual selection or word' })

map('n', '<leader>s"', builtin.registers, { desc = 'Registers' })

map('n', '<leader>s/', builtin.search_history, { desc = 'Search History' })

map('n', '<leader>sa', builtin.autocommands, { desc = 'Find Autocmds' })

---------------------------------------------------------------------
-- LSP (Telescope builtins)
---------------------------------------------------------------------
local function map_lsp(telescope_fn, fallback)
  return function()
    local ok = pcall(function()
      builtin[telescope_fn]()
    end)

    if not ok then
      fallback()
    end
  end
end
map('n', 'grd', map_lsp('lsp_definitions', vim.lsp.buf.definition), { desc = 'Goto Definition' })

map('n', 'grD', map_lsp('lsp_declarations', vim.lsp.buf.declaration), { desc = 'Goto Declaration' })

map('n', 'gri', map_lsp('lsp_implementations', vim.lsp.buf.implementation), { desc = 'Goto Implementation' })

map('n', 'gry', map_lsp('lsp_type_definitions', vim.lsp.buf.type_definition), { desc = 'Goto Type Definition' })

map('n', 'grx', map_lsp('lsp_references', vim.lsp.buf.references), { desc = 'References', nowait = true })

map({ 'n', 'v' }, '<leader>le', function()
  builtin.diagnostics()
end, { desc = 'All Diagnostics' })
