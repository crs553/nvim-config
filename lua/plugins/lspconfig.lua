-- Mason
vim.pack.add({ { src = "https://github.com/williamboman/mason.nvim" } })
vim.pack.add({ { src = "https://github.com/williamboman/mason-lspconfig.nvim" } })

-- LSP Config
vim.pack.add({ { src = "https://github.com/neovim/nvim-lspconfig" } })

-- CMP + Snippets
vim.pack.add({
  { src = "https://github.com/hrsh7th/nvim-cmp" },
  { src = "https://github.com/hrsh7th/cmp-nvim-lsp" },
  { src = "https://github.com/hrsh7th/cmp-buffer" },
  { src = "https://github.com/hrsh7th/cmp-path" },
  { src = "https://github.com/hrsh7th/cmp-cmdline" },
  { src = "https://github.com/L3MON4D3/LuaSnip" },
  { src = "https://github.com/rafamadriz/friendly-snippets" },
})

-- ======================
-- Mason Setup
-- ======================
require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = { "lua_ls", "matlab_ls", "pylsp", "marksman", "ltex_plus" },
})

-- ======================
-- LSP Setup
-- ======================
-- Ensure cmp_nvim_lsp is loaded
local has_cmp_lsp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if not has_cmp_lsp then
  vim.notify("cmp_nvim_lsp not found!", vim.log.levels.WARN)
  return
end

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = cmp_nvim_lsp.default_capabilities(capabilities)

-- Common on_attach for all LSPs
local on_attach = function(_, bufnr)
  local map = function(mode, keys, func, desc)
    vim.keymap.set(mode, keys, func, { buffer = bufnr, desc = "LSP: " .. desc })
  end

  map("n", "<space>lh", vim.lsp.buf.hover, "Hover")
  map("n", "<space>ld", vim.lsp.buf.definition, "Go to definition")
  map("n", "<space>lr", vim.lsp.buf.rename, "Rename symbol")
end

local lspconfig = require("lspconfig")

-- Lua
lspconfig.lua_ls.setup({
  on_attach = on_attach,
  capabilities = capabilities,
  filetypes = { "lua" },
  settings = {
    Lua = {
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
    },
  },
})

-- LTEX Plus
lspconfig.ltex_plus.setup({
  on_attach = on_attach,
  capabilities = capabilities,
  filetypes = { "markdown", "tex", "text", "gitcommit", "bib" },
  settings = {
    ltex = {
      language = "en-GB",
      diagnosticSeverity = "information",
      disabledRules = { "MORFOLOGIK_RULE_EN_GB", "OXFORD_SPELLING_NOUNS" },
      dictionary = { ["en-GB"] = { "Neovim", "Lua", "Eurospin", "radiofrequency", "MagIQ" } },
      setPreferences = { variant = "GB", allowVariants = false },
      sentenceCacheSize = 2000,
    },
  },
})

-- MATLAB
lspconfig.matlab_ls.setup({
  filetypes = { "matlab" },
  settings = {
    MATLAB = {
      installPath = "C:\\Program Files\\MATLAB\\R2024b\\",
      matlabConnectionTiming = "onStart",
      telemetry = true,
      verboseLogging = true,
    },
  },
  on_attach = on_attach,
  capabilities = capabilities,
  single_file_support = true,
})

-- Python (pylsp + mypy)
lspconfig.pylsp.setup({
  on_attach = on_attach,
  capabilities = capabilities,
  settings = {
    pylsp = {
      plugins = {
        pycodestyle = { enabled = false },
        mypy = { enabled = true, live_mode = true, dmypy = true, struct = true, report_progress = true },
        black = { enabled = true },
        isort = { enabled = true },
      },
    },
  },
})

-- ======================
-- nvim-cmp Setup
-- ======================
local cmp = require("cmp")
local luasnip = require("luasnip")
require("luasnip.loaders.from_vscode").lazy_load()

cmp.setup({
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ["<C-n>"] = cmp.mapping.select_next_item(),
    ["<C-p>"] = cmp.mapping.select_prev_item(),
    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),
    ["<C-y>"] = cmp.mapping.confirm({ select = true }),
    ["<C-e>"] = cmp.mapping.abort(),
    ["<CR>"] = cmp.mapping.confirm({ select = false }),
  }),
  sources = cmp.config.sources({
    { name = "nvim_lsp" },
    { name = "luasnip" },
    { name = "buffer" },
    { name = "path" },
  }),
  experimental = { ghost_text = true },
})

-- CMP for cmdline
cmp.setup.cmdline({ "/", "?" }, { mapping = cmp.mapping.preset.cmdline(), sources = { { name = "buffer" } } })
cmp.setup.cmdline(":", {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({ { name = "path" } }, { { name = "cmdline" } }),
})
