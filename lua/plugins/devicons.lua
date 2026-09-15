-- nvim-web-devicons overrides for MATLAB / data files
require('nvim-web-devicons').setup {
  override_by_extension = {
    ['m'] = { icon = '', color = '#FF853B', name = 'matlab' },
    ['mat'] = { icon = '', color = '#FF853B', name = 'matlab' },
    ['dat'] = { icon = '', color = '#721080', name = 'data' },
  },
}
