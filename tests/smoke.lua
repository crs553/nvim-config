local required_modules = {
  -- Core configuration
  'config.keymaps',
  'config.autocmds',
  'config.options',
  'config.lazy',
  'config.notify',
  'config.floaterm',
  'config.packclean',
  'config.git',

  -- Plugin configuration
  'plugins.declarations',
  'plugins.colorschemes',
  'plugins.comment',
  'plugins.conform',
  'plugins.dap',
  'plugins.fidget',
  'plugins.gitsigns',
  'plugins.lspconfig',
  'plugins.lint',
  'plugins.lualine',
  'plugins.markdown',
  'plugins.oil',
  'plugins.quicker',
  'plugins.snacks',
  'plugins.surround',
  'plugins.treesitter',
  'plugins.textobjects',
  'plugins.picker',
  'plugins.todo',
  'plugins.session',
  'plugins.undotree',
  'plugins.ai',
  'plugins.obsidian',
  'plugins.whichkey',
}

for _, module in ipairs(required_modules) do
  assert(package.loaded[module] ~= nil, ('Module was not loaded: %s'):format(module))
end

print(('Smoke test passed: %d configuration modules loaded'):format(#required_modules))
