-- Lualine setup
require('lualine').setup {
  options = {
    theme = 'auto',
    section_separators = { left = '', right = '' },
    component_separators = { left = '', right = '' },
    globalstatus = true,
    disabled_filetypes = {
      'NvimTree',
      'neo-tree',
      'TelescopePrompt',
      'alpha',
      'dashboard',
    },
  },
  sections = {
    lualine_a = { 'mode' },
    lualine_b = { 'branch', 'diff' },
    lualine_c = {
      { 'filename', file_status = true, path = 1 },
    },
    lualine_x = {
      'encoding',
      'fileformat',
      'filetype',
      { 'progress', separator = ' ', padding = 1 },
      { 'diagnostics', sources = { 'nvim_diagnostic', 'nvim_lsp' } },
    },
    lualine_y = {},
    lualine_z = { 'location' },
  },
  tabline = {
    lualine_a = { 'buffers' },
    lualine_b = {},
    lualine_c = {},
    lualine_x = {},
    lualine_y = {},
    lualine_z = { 'tabs' },
  },
}
