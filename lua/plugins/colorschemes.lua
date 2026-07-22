require('catppuccin').setup {
  flavour = 'mocha',
  transparent_background = false,
  term_colors = true,
  show_end_of_buffer = false,

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
      LineNr = {
        fg = colors.overlay1,
      },

      CursorLineNr = {
        fg = colors.mauve,
        bold = true,
      },

      CursorLine = {
        bg = colors.surface0,
      },

      CursorLineSign = {
        bg = colors.surface0,
      },

      -- Visual selection
      Visual = {
        bg = colors.surface1,
      },

      -- Search
      Search = {
        bg = colors.surface2,
        fg = colors.text,
      },

      IncSearch = {
        bg = colors.pink,
        fg = colors.base,
      },

      -- Floating windows
      NormalFloat = {
        bg = colors.mantle,
      },

      FloatBorder = {
        fg = colors.mauve,
        bg = colors.mantle,
      },

      FloatTitle = {
        fg = colors.mauve,
        bold = true,
      },

      -- Telescope
      TelescopeBorder = {
        fg = colors.mauve,
      },

      TelescopePromptBorder = {
        fg = colors.mauve,
      },

      TelescopeSelection = {
        bg = colors.surface0,
      },

      -- Completion menu
      PmenuSel = {
        bg = colors.mauve,
        fg = colors.base,
      },

      -- WhichKey
      WhichKey = {
        fg = colors.mauve,
      },
    }
  end,
}

vim.cmd.colorscheme('catppuccin-mocha')
