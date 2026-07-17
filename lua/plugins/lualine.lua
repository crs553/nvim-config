-- Lualine setup
require('lualine').setup {
  options = {
    icons_enabled = true,
    theme = 'auto',
    section_separators = { left = '', right = '' },
    component_separators = { left = '', right = '' },
    globalstatus = true,
    disabled_filetypes = {
      'NvimTree',
      'neo-tree',
      'alpha',
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
      {
        function()
          local clients = vim.lsp.get_clients { bufnr = 0 }
          if #clients == 0 then
            return '󰛦 None'
          end
          local names = {}
          for _, client in ipairs(clients) do
            table.insert(names, client.name)
          end
          return '󰛦 ' .. table.concat(names, ' ')
        end,
      },
    },
    lualine_y = {},
    lualine_z = { 'location', 'searchcount' },
  },
}
