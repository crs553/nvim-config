local lazy = require 'config.lazy'

lazy.setup(function()
  if not vim.g.is_nixos and vim.env.NVIM_SKIP_MASON ~= '1' then
    require('mason-nvim-lint').setup {
      ensure_installed = {
        'markdownlint',
        'shellcheck',
        'yamllint',
        'jsonlint',
      },
      automatic_install = false,
    }
  end

  local lint = require 'lint'

  lint.linters_by_ft = {
    python = { 'ruff' },
    -- lua = { "luacheck" }, -- doesn't work on windows
    sh = { 'shellcheck' },
    zsh = { 'shellcheck' },
    bash = { 'shellcheck' },
    markdown = { 'markdownlint' },
    yaml = { 'yamllint' },
    json = { 'jsonlint' },
  }

  -- Auto-lint on save and on insert leave
  local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })
  vim.api.nvim_create_autocmd({ 'BufWritePost', 'InsertLeave' }, {
    group = lint_augroup,
    callback = function()
      local linters = lint.linters_by_ft[vim.bo.filetype]

      if vim.bo.modifiable and linters and #linters > 0 then lint.try_lint() end
    end,
  })

  -- Keymap: manually lint current buffer
  vim.keymap.set('n', '<leader>ll', function() lint.try_lint() end, { desc = 'Lint buffer' })
end)
