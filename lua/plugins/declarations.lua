local function run_build(name, cmd, cwd)
  local result = vim.system(cmd, { cwd = cwd }):wait()
  if result.code ~= 0 then
    local stderr = result.stderr or ''
    local stdout = result.stdout or ''
    local output = stderr ~= '' and stderr or stdout
    if output == '' then output = 'No output from build command.' end
    vim.notify(('Build failed for %s:\n%s'):format(name, output), vim.log.levels.ERROR)
  end
end

-- This autocommand runs after a plugin is installed or updated and
--  runs the appropriate build command for that plugin if necessary.
--
-- See `:help vim.pack-events`
vim.api.nvim_create_autocmd('PackChanged', {
  callback = function(ev)
    local name = ev.data.spec.name
    local kind = ev.data.kind
    if kind ~= 'install' and kind ~= 'update' then return end

    if name == 'LuaSnip' then
      if vim.fn.has 'win32' ~= 1 and vim.fn.executable 'make' == 1 then
        run_build(name, { 'make', 'install_jsregexp' }, ev.data.path)
      end
      return
    end

    if name == 'nvim-treesitter' then
      if not ev.data.active then vim.cmd.packadd 'nvim-treesitter' end
      vim.cmd 'TSUpdate'
      return
    end
  end,
})

---Because most plugins are hosted on GitHub, you can use the helper
---function to have less repetition in the following sections.
---@param repo string
---@return string
local function gh(repo) return 'https://github.com/' .. repo end

-- Foundational (declare first so other plugins can require them)
vim.pack.add { gh 'nvim-lua/plenary.nvim' }

-- Colorscheme
vim.pack.add { { src = gh 'catppuccin/nvim', name = 'catppuccin' } }

-- UI / Visual
vim.pack.add {
  gh 'nvim-lualine/lualine.nvim',
  gh 'nvim-tree/nvim-web-devicons',
}
vim.pack.add {
  gh 'folke/which-key.nvim',
  gh 'nvim-mini/mini.icons',
}
vim.pack.add {
  { src = gh 'folke/snacks.nvim' },
}

-- Editor features
vim.pack.add { gh 'lewis6991/gitsigns.nvim' }
vim.pack.add {
  {
    src = gh 'kylechui/nvim-surround',
  },
}
vim.pack.add { { src = gh 'nvim-mini/mini.comment', version = 'stable' } }
vim.pack.add {
  { src = gh 'stevearc/conform.nvim' },
}
vim.pack.add {
  gh 'mfussenegger/nvim-lint',
  gh 'rshkarin/mason-nvim-lint',
}

-- Indentation guides (handled by snacks.indent)

-- Treesitter
vim.pack.add {
  { src = gh 'nvim-treesitter/nvim-treesitter' },
}

-- LSP
vim.pack.add { { src = gh 'neovim/nvim-lspconfig' } }
vim.pack.add { { src = gh 'williamboman/mason.nvim' } }
vim.pack.add { { src = gh 'williamboman/mason-lspconfig.nvim' } }

-- CMP & Snippets
vim.pack.add {
  { src = gh 'hrsh7th/nvim-cmp' },
  { src = gh 'hrsh7th/cmp-nvim-lsp' },
  { src = gh 'hrsh7th/cmp-buffer' },
  { src = gh 'hrsh7th/cmp-path' },
  { src = gh 'hrsh7th/cmp-cmdline' },
  { src = gh 'L3MON4D3/LuaSnip' },
  { src = gh 'rafamadriz/friendly-snippets' },
  { src = gh 'tzachar/cmp-ai' },
}

-- AI
vim.pack.add {
  { src = gh 'olimorris/codecompanion.nvim', version = 'v19.13.0' },
}

-- DAP
vim.pack.add {
  { src = 'https://codeberg.org/mfussenegger/nvim-dap.git' },
  { src = gh 'rcarriga/nvim-dap-ui' },
  { src = gh 'theHamsta/nvim-dap-virtual-text' },
  { src = gh 'leoluz/nvim-dap-go' },
  { src = gh 'mfussenegger/nvim-dap-python' },
  { src = gh 'nvim-neotest/nvim-nio' },
}

-- File navigation
vim.pack.add { { src = gh 'stevearc/oil.nvim' } }
vim.pack.add {
  gh 'tadmccorkle/markdown.nvim',
  gh 'MeanderingProgrammer/render-markdown.nvim',
}
vim.pack.add {
  { src = gh 'obsidian-nvim/obsidian.nvim', version = 'v3.16.3' },
}
vim.pack.add { { src = gh 'stevearc/quicker.nvim' } }

-- Other
vim.pack.add {
  gh 'theprimeagen/vim-be-good',
}
