-- ======================
-- Mason Setup
-- ======================
if not vim.g.is_nixos then
  require('mason').setup()
  require('mason-lspconfig').setup {
    ensure_installed = {
      'arduino_language_server',
      'bashls',
      'harper_ls',
      'lua_ls',
      'marksman',
      'rust_analyzer',
      'ruff',
      'typescript-language-server',
      'vscode-langservers-extracted',
      'yaml-language-server',
    },
  }
end

-- ======================
-- LSP Capabilities & on_attach
-- ======================
local has_cmp_lsp, cmp_nvim_lsp = pcall(require, 'cmp_nvim_lsp')
if not has_cmp_lsp then
  vim.notify('cmp_nvim_lsp not found!', vim.log.levels.WARN)
  return
end

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = cmp_nvim_lsp.default_capabilities(capabilities)

local on_attach = function(_, bufnr)
  local map = function(mode, keys, func, desc)
    vim.keymap.set(mode, keys, func, { buffer = bufnr, desc = 'LSP: ' .. desc })
  end

  map('n', '<leader>lh', vim.lsp.buf.hover, 'Hover')
  map('n', '<leader>ld', vim.lsp.buf.definition, 'Definition')
  map('n', '<leader>lr', vim.lsp.buf.rename, 'Rename')
  map('n', '<leader>la', vim.lsp.buf.code_action, 'Code Action')
  map('n', '<leader>lb', vim.lsp.buf.format, 'Format Buffer (LSP)')
  map('n', '<leader>ls', vim.lsp.buf.signature_help, 'Signature Help')
end

-- Arduino Language Server
vim.lsp.config['arduino_language_server'] = {
  on_attach = on_attach,
  capabilities = capabilities,
  root_dir = vim.uv.cwd,
}

vim.lsp.enable('arduino_language_server')
vim.lsp.config['bashls'] = {
  on_attach = on_attach,
  capabilities = capabilities,
}
vim.lsp.enable('bashls')

vim.lsp.config['harper_ls'] = {
  on_attach = on_attach,
  capabilities = capabilities,
}
vim.lsp.enable('harper_ls')

vim.lsp.config['gopls'] = {
  capabilities = capabilities,
  on_attach = on_attach,
  settings = {
    gopls = {
      analyses = {
        unusedparams = true,
        shadow = true,
      },
      staticcheck = true,
      gofumpt = true,
      completeUnimported = true,
      usePlaceholders = true,
      -- Enable inlay hints for better variable type visibility
      hints = {
        assignVariableTypes = true,
        compositeLiteralFields = true,
        compositeLiteralTypes = true,
        constantValues = true,
        functionTypeParameters = true,
        parameterNames = true,
        rangeVariableTypes = true,
      },
    },
  },
}
vim.lsp.enable('gopls')

-- Lua
vim.lsp.config['lua_ls'] = {
  on_attach = on_attach,
  capabilities = capabilities,
  filetypes = { 'lua' },
  settings = {
    Lua = {
      workspace = {
        checkThirdParty = false,
        library = vim.api.nvim_get_runtime_file('lua', true),
      },
      telemetry = { enable = false },
    },
  },
}
vim.lsp.enable('lua_ls')

-- TypeScript/JavaScript
vim.lsp.config['ts_ls'] = {
  on_attach = on_attach,
  capabilities = capabilities,
  root_markers = { 'tsconfig.json', 'jsconfig.json', 'package.json', '.git' },
  single_file_support = true,
  settings = {
    typescript = {
      inlayHints = {
        parameterNames = { enabled = 'all' },
        parameterTypes = { enabled = true },
        variableTypes = { enabled = true },
        propertyDeclarationTypes = { enabled = true },
        functionLikeReturnTypes = { enabled = true },
        enumMemberValues = { enabled = true },
      },
    },
    javascript = {
      inlayHints = {
        parameterNames = { enabled = 'all' },
        parameterTypes = { enabled = true },
        variableTypes = { enabled = true },
        propertyDeclarationTypes = { enabled = true },
        functionLikeReturnTypes = { enabled = true },
        enumMemberValues = { enabled = true },
      },
    },
  },
}
vim.lsp.enable('ts_ls')

-- CSS
vim.lsp.config['cssls'] = {
  on_attach = on_attach,
  capabilities = capabilities,
  single_file_support = true,
}
vim.lsp.enable('cssls')

-- HTML
vim.lsp.config['html'] = {
  on_attach = on_attach,
  capabilities = capabilities,
  single_file_support = true,
}
vim.lsp.enable('html')

-- JSON
vim.lsp.config['jsonls'] = {
  on_attach = on_attach,
  capabilities = capabilities,
  single_file_support = true,
  settings = {
    json = {
      validate = { enable = true },
    },
  },
}
vim.lsp.enable('jsonls')

-- YAML
vim.lsp.config['yamlls'] = {
  on_attach = on_attach,
  capabilities = capabilities,
  single_file_support = true,
  settings = {
    yaml = {
      schemaStore = { enable = true, url = '' },
      validate = true,
    },
  },
}
vim.lsp.enable('yamlls')

vim.lsp.config['rust_analyzer'] = {
  on_attach = on_attach,
  capabilities = capabilities,
  cmd = { 'rust-analyzer' },
  filetypes = { 'rust' },
  root_markers = { 'Cargo.toml', '.git' },
  single_file_support = true,
  settings = {
    rust_analyzer = {
      cargo = { allFeatures = true },
      check = {
        command = 'clippy',
      },
      procMacro = { enable = true },
    },
  },
}
vim.lsp.enable('rust_analyzer')

-- MATLAB -- note I managed this externally as the Mason files were not working for me
vim.lsp.config['matlab_ls'] = {
  capabilities = capabilities,
  on_attach = on_attach,
  cmd = { 'matlab-language-server', '--stdio' },
  filetypes = { 'matlab' },
  root_dir = function(bufnr)
    return vim.fs.root(bufnr, '.git') or vim.fn.getcwd()
  end,
  settings = {
    MATLAB = {
      indexWorkspace = false,
      matlabconnectiontiming = 'onDemand',
      telemetry = true,
      installPath = 'C:\\Program Files\\MATLAB\\R2024b',
    },
  },
  single_file_support = true,
}
vim.lsp.enable('matlab_ls')

-- Python (ruff)
-- ruff provides linting, formatting, and import organization.
-- For code intelligence (completions, goto-def, hover), pair with basedpyright.
vim.lsp.config['ruff'] = {
  on_attach = on_attach,
  capabilities = capabilities,
  filetypes = { 'python' },
  root_markers = { 'pyproject.toml', 'ruff.toml', '.ruff.toml', 'setup.py', 'setup.cfg', '.git' },
  single_file_support = true,
  settings = {
    ruff = {
      format = { enable = true },
      fixAll = true,
      organizeImports = true,
      lint = { enable = true },
    },
  },
}
vim.lsp.enable('ruff')

-- nvim-cmp Setup
local cmp = require('cmp')
local luasnip = require('luasnip')
require('luasnip.loaders.from_vscode').lazy_load()

-- cmp-ai: AI completion via LM Studio
local cmp_ai = require('cmp_ai.config')

cmp_ai:setup {
  provider = 'openai',
  provider_options = {
    url = 'http://127.0.0.1:1234/v1/chat/completions',
    model = 'qwen2.5-coder-7b-instruct',
    api_key = 'lmstudio',
    max_tokens = 64,
    temperature = 0.1,
  },
  notify = false,
  run_on_every_keystroke = false,
  max_timeout_seconds = 5,
  max_lines = 100,
  max_chars = 1000,
}

cmp.setup {
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },

  mapping = cmp.mapping.preset.insert {
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),

    -- only accept with C-y
    ['<C-y>'] = cmp.mapping.confirm { select = true },

    -- enter disabled for completion (always fallback newline)
    ['<CR>'] = cmp.mapping(function(fallback)
      fallback()
    end, { 'i', 's' }),

    ['<C-e>'] = cmp.mapping.abort(),
  },

  -- PRIORITY ORDER
  sources = cmp.config.sources({
    { name = 'cmp_ai', priority = 850 },
    { name = 'nvim_lsp', priority = 800 },
    { name = 'luasnip', priority = 700 },
    { name = 'codecompanion', priority = 600 },
  }, {
    { name = 'buffer', priority = 500 },
    { name = 'path', priority = 300 },
  }),

  -- CLEAR LABELS IN MENU
  formatting = {
    format = function(entry, vim_item)
      vim_item.menu = ({
        cmp_ai = '󰚩 AI',
        nvim_lsp = '󰛦 LSP',
        luasnip = '󰩫 Snip',
        buffer = '󰈙 Buf',
        path = '󰉋 Path',
      })[entry.source.name]

      return vim_item
    end,
  },

  -- BETTER SORTING (keeps AI stable at top)
  sorting = {
    priority_weight = 2,
    comparators = {
      require('cmp').config.compare.offset,
      require('cmp').config.compare.exact,
      require('cmp').config.compare.score,
      require('cmp').config.compare.recently_used,
      require('cmp').config.compare.kind,
      require('cmp').config.compare.sort_text,
      require('cmp').config.compare.length,
      require('cmp').config.compare.order,
    },
  },

  experimental = {
    ghost_text = true,
  },
} -- CMP cmdline support
cmp.setup.cmdline({ '/', '?' }, { mapping = cmp.mapping.preset.cmdline(), sources = { { name = 'buffer' } } })
cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({ { name = 'path' } }, { { name = 'cmdline' } }),
})
