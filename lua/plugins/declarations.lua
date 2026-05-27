-- Foundational (declare first so other plugins can require them)
vim.pack.add { 'https://github.com/nvim-lua/plenary.nvim' }

-- Colorscheme
vim.pack.add { { src = 'https://github.com/catppuccin/nvim', name = 'catppuccin' } }

-- UI / Visual
vim.pack.add {
  'https://github.com/nvim-lualine/lualine.nvim',
  'https://github.com/nvim-tree/nvim-web-devicons',
}
vim.pack.add {
  'https://github.com/folke/which-key.nvim',
  'https://github.com/nvim-mini/mini.icons',
}
vim.pack.add {
  { src = 'https://github.com/folke/snacks.nvim' },
}

-- Editor features
vim.pack.add { 'https://github.com/lewis6991/gitsigns.nvim' }
vim.pack.add {
  {
    src = 'https://github.com/kylechui/nvim-surround',
  },
}
vim.pack.add { { src = 'https://github.com/nvim-mini/mini.comment', version = 'stable' } }
vim.pack.add {
  { src = 'https://github.com/stevearc/conform.nvim' },
}
vim.pack.add {
  'https://github.com/mfussenegger/nvim-lint',
  'https://github.com/rshkarin/mason-nvim-lint',
}

-- Treesitter
vim.pack.add {
  {
    src = 'https://github.com/nvim-treesitter/nvim-treesitter',
    commit = '4916d6592ede8c07973490d9322f187e07dfefac',
  },
}

-- LSP
vim.pack.add { { src = 'https://github.com/neovim/nvim-lspconfig' } }
vim.pack.add { { src = 'https://github.com/williamboman/mason.nvim' } }
vim.pack.add { { src = 'https://github.com/williamboman/mason-lspconfig.nvim' } }

-- CMP & Snippets
vim.pack.add {
  { src = 'https://github.com/hrsh7th/nvim-cmp' },
  { src = 'https://github.com/hrsh7th/cmp-nvim-lsp' },
  { src = 'https://github.com/hrsh7th/cmp-buffer' },
  { src = 'https://github.com/hrsh7th/cmp-path' },
  { src = 'https://github.com/hrsh7th/cmp-cmdline' },
  { src = 'https://github.com/L3MON4D3/LuaSnip' },
  { src = 'https://github.com/rafamadriz/friendly-snippets' },
  { src = 'https://github.com/tzachar/cmp-ai' },
}

-- AI
vim.pack.add {
  { src = 'https://github.com/olimorris/codecompanion.nvim', version = 'v19.13.0' },
  { src = 'https://github.com/nvim-mini/mini.diff' },
}

-- DAP
vim.pack.add {
  { src = 'https://codeberg.org/mfussenegger/nvim-dap.git' },
  { src = 'https://github.com/rcarriga/nvim-dap-ui' },
  { src = 'https://github.com/theHamsta/nvim-dap-virtual-text' },
  { src = 'https://github.com/leoluz/nvim-dap-go' },
  { src = 'https://github.com/mfussenegger/nvim-dap-python' },
  { src = 'https://github.com/nvim-neotest/nvim-nio' },
}

-- Telescope
vim.pack.add {
  'https://github.com/nvim-telescope/telescope.nvim',
  'https://github.com/nvim-telescope/telescope-fzf-native.nvim',
}

-- File navigation
vim.pack.add { { src = 'https://github.com/stevearc/oil.nvim' } }
vim.pack.add {
  'https://github.com/tadmccorkle/markdown.nvim',
  'https://github.com/MeanderingProgrammer/render-markdown.nvim',
}
vim.pack.add {
  { src = 'https://github.com/obsidian-nvim/obsidian.nvim', version = 'v3.16.3' },
}
vim.pack.add { { src = 'https://github.com/stevearc/quicker.nvim.git' } }

-- Other
vim.pack.add {
  'https://github.com/theprimeagen/vim-be-good',
}
