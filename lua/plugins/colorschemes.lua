require('catppuccin').setup {
  flavour = 'mocha',
  transparent_background = false,
  styles = {
    comments = { 'italic' },
    conditionals = { 'italic' },
  },
  integrations = {
    treesitter = true,
    native_lsp = { enabled = true },
    telescope = true,
    which_key = true,
    cmp = true,
    lualine = true,
    gitsigns = true,
    dap = { enabled = true },
    oil = true,
    markdown = true,
    mini = { enabled = true },
    snacks = { enabled = true },
  },

  custom_highlights = function(colors)
    return {
      -- Line numbers
      LineNr = { fg = colors.overlay1 },
      CursorLineNr = { fg = colors.mauve, style = { 'bold' } },
      CursorLine = { bg = colors.surface0 },

      -- Visual selection
      Visual = { bg = colors.surface1 },

      -- Search highlights
      Search = { bg = colors.mauve, fg = colors.base },
      IncSearch = { bg = colors.pink, fg = colors.base },

      -- Telescope
      TelescopeBorder = { fg = colors.mauve },
      TelescopePromptBorder = { fg = colors.mauve },
      TelescopeSelection = { bg = colors.surface0 },

      -- CMP completion menu
      PmenuSel = { bg = colors.mauve, fg = colors.base },

      -- WhichKey
      WhichKey = { fg = colors.mauve },

      -- Floating windows
      FloatBorder = { fg = colors.mauve },
    }
  end,
}
vim.cmd([[colorscheme catppuccin-mocha]])
