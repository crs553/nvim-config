-- ======================
-- Mason Setup
-- ======================
local lazy = require 'config.lazy'

lazy.setup(function()
  if not vim.g.is_nixos and vim.env.NVIM_SKIP_MASON ~= '1' then
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
        'biome',
        'basedpyright',
      },
    }
  end
end)

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

--- Configure and enable an LSP server with shared defaults.
---@param server string
---@param opts? table  Extra config merged into the server config.
local function lsp(server, opts)
  opts = opts or {}
  opts.on_attach = opts.on_attach or on_attach
  opts.capabilities = opts.capabilities or capabilities
  vim.lsp.config[server] = opts
  vim.lsp.enable(server)
end

-- Arduino Language Server
lsp('arduino_language_server', { root_dir = vim.uv.cwd })

lsp 'bashls'
-- Grammar & prose linter (British English)
lsp('harper_ls', {
  settings = {
    ['harper-ls'] = {
      linters = {
        SpellCheck = true,
        SpelledNumbers = false,
        AnA = true,
        SentenceCapitalization = true,
        UnclosedQuotes = true,
        WrongApostrophe = false,
        LongSentences = true,
        RepeatedWords = true,
        Spaces = true,
        CorrectNumberSuffix = true,
      },
      codeActions = { ForceStable = false },
      markdown = { IgnoreLinkTitle = false },
      diagnosticSeverity = 'hint',
      dialect = 'British',
      maxFileLength = 120000,
      isolateEnglish = false,
      userDictPath = '',
      workspaceDictPath = '',
      fileDictPath = '',
      ignoredLintsPath = '',
      excludePatterns = {},
    },
  },
})

-- Go
lsp('gopls', {
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
})

-- Lua
lsp('lua_ls', {
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
})

-- TypeScript/JavaScript
lsp('ts_ls', {
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
})

-- CSS
lsp('cssls', { single_file_support = true })

-- HTML
lsp('html', { single_file_support = true })

-- JSON
lsp('jsonls', {
  single_file_support = true,
  settings = {
    json = {
      validate = { enable = true },
    },
  },
})

-- YAML
lsp('yamlls', {
  single_file_support = true,
  settings = {
    yaml = {
      schemaStore = { enable = true, url = '' },
      validate = true,
    },
  },
})

-- Biome (linting + formatting for JS/TS/JSON/CSS/HTML)
-- Requires biome.json / biome.jsonc in project root to activate.
lsp('biome', {
  filetypes = {
    'astro',
    'css',
    'graphql',
    'html',
    'javascript',
    'javascriptreact',
    'json',
    'jsonc',
    'svelte',
    'typescript',
    'typescriptreact',
    'vue',
  },
  root_markers = {
    'biome.json',
    'biome.jsonc',
    '.biome.json',
    '.biome.jsonc',
  },
  single_file_support = false,
})

-- Disable ts_ls formatting for buffers where biome is active
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('biome_override', { clear = true }),
  callback = function(args)
    local clients = vim.lsp.get_clients { id = args.data.client_id }
    local client = clients[1]
    if client and client.name == 'biome' then
      local ts_clients = vim.lsp.get_clients { name = 'ts_ls', bufnr = args.buf }
      for _, ts_client in ipairs(ts_clients) do
        ts_client.server_capabilities.documentFormattingProvider = false
        ts_client.server_capabilities.documentRangeFormattingProvider = false
      end
    end
  end,
})

-- Rust
lsp('rust_analyzer', {
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
})

-- Nix (nixd)
lsp('nixd', {
  filetypes = { 'nix' },
  root_markers = { 'flake.nix', 'flake.lock', '.git' },
  single_file_support = true,
})

-- MATLAB
lsp('matlab_ls', {
  cmd = {
    'C:/Users/charlie/scoop/apps/nodejs-lts/current/node.exe',
    'C:/Users/charlie/Documents/MATLAB-language-server/out/index.js',
    '--stdio',
  },
  filetypes = { 'matlab' },
  root_markers = { '.git' },
  settings = {
    MATLAB = {
      indexWorkspace = false,
      matlabConnectionTiming = 'onStart',
      telemetry = false,
      installPath = 'C:\\Program Files\\MATLAB\\R2024b',
    },
  },
  single_file_support = true,
})

-- Python (ruff)
-- ruff provides linting, formatting, and import organization.
-- For code intelligence (completions, goto-def, hover), pair with basedpyright.
lsp('ruff', {
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
})

-- Python (basedpyright)
-- Type checking + code intelligence (completions, goto-def, hover, rename).
-- ruff handles linting/formatting; the two are designed to pair.
lsp('basedpyright', {
  filetypes = { 'python' },
  root_markers = { 'pyproject.toml', 'pyrightconfig.json', 'setup.py', 'setup.cfg', '.git' },
  single_file_support = true,
  settings = {
    basedpyright = {
      analysis = {
        typeCheckingMode = 'basic',
        useLibraryCodeForTypes = true,
        autoSearchPaths = true,
        diagnosticMode = 'openFilesOnly',
      },
    },
  },
})

-- nvim-cmp Setup (deferred until first insert to keep startup fast)
lazy.on('InsertEnter', function()
  local cmp = require 'cmp'
  local luasnip = require 'luasnip'
  require('luasnip.loaders.from_vscode').lazy_load()

  -- cmp-ai: AI completion via LM Studio
  local cmp_ai = require 'cmp_ai.config'

  cmp_ai:setup {
    provider = 'openai',
    provider_options = {
      url = 'http://127.0.0.1:1234/v1/chat/completions',
      model = 'qwen/qwen3.5-9b',
      api_key = 'lmstudio',
      max_tokens = 64,
      temperature = 0.2,
    },
    notify = false,
    run_on_every_keystroke = false,
    max_timeout_seconds = 5,
    max_lines = 100,
    max_chars = 1000,
  }

  cmp.setup {
    snippet = {
      expand = function(args) luasnip.lsp_expand(args.body) end,
    },

    mapping = cmp.mapping.preset.insert {
      ['<C-n>'] = cmp.mapping.select_next_item(),
      ['<C-p>'] = cmp.mapping.select_prev_item(),
      ['<C-b>'] = cmp.mapping.scroll_docs(-4),
      ['<C-f>'] = cmp.mapping.scroll_docs(4),

      -- only accept with C-y
      ['<C-y>'] = cmp.mapping.confirm { select = true },

      -- confirm selected item, otherwise insert newline
      ['<CR>'] = cmp.mapping.confirm { select = false },

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

    sorting = {
      priority_weight = 2,
      comparators = {
        cmp.config.compare.offset,
        cmp.config.compare.exact,
        cmp.config.compare.score,
        cmp.config.compare.recently_used,
        cmp.config.compare.kind,
        cmp.config.compare.sort_text,
        cmp.config.compare.length,
        cmp.config.compare.order,
      },
    },

    experimental = {
      ghost_text = true,
    },
  }

  cmp.setup.cmdline(
    { '/', '?' },
    { mapping = cmp.mapping.preset.cmdline(), sources = { { name = 'buffer' } } }
  )
  cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({ { name = 'path' } }, { { name = 'cmdline' } }),
  })
end)
