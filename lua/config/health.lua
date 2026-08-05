--[[
--
-- Health check for this nvim config.
-- Run with `:checkhealth config` (or plain `:checkhealth`).
--
--]]

local check_version = function()
  local verstr = tostring(vim.version())
  if not vim.version.ge then
    vim.health.error(
      string.format("Neovim out of date: '%s'. Upgrade to latest stable or nightly", verstr)
    )
    return
  end

  if vim.version.ge(vim.version(), '0.12') then
    vim.health.ok(string.format("Neovim version is: '%s'", verstr))
  else
    vim.health.error(
      string.format(
        "Neovim out of date: '%s'. This config uses the built-in vim.pack plugin manager (Neovim 0.12+)",
        verstr
      )
    )
  end
end

local check_external_reqs = function()
  -- Core tools required by vim.pack and plugins
  for _, exe in ipairs { 'git', 'curl', 'make', 'unzip', 'rg' } do
    if vim.fn.executable(exe) == 1 then
      vim.health.ok(string.format("Found executable: '%s'", exe))
    else
      vim.health.warn(string.format("Could not find executable: '%s'", exe))
    end
  end

  -- Optional tools: only needed if you use the associated feature
  local optional = {
    { 'lazygit', 'floating git UI (<leader>gg)' },
    { 'opencode', 'CodeCompanion agent (interactions.agent)' },
    { 'python', 'Python DAP and ruff LSP' },
    { 'go', 'gopls LSP' },
    { 'dlv', 'Go DAP (delve) via nvim-dap-go' },
    { 'node', 'prettier / markdownlint / jsonlint (via npm)' },
    { 'prettier', 'Markdown and YAML formatting' },
    { 'stylua', 'Lua formatting' },
    { 'rustfmt', 'Rust formatting' },
  }
  for _, item in ipairs(optional) do
    local exe, use = item[1], item[2]
    if vim.fn.executable(exe) == 1 then
      vim.health.ok(string.format("Found optional executable: '%s' (%s)", exe, use))
    else
      vim.health.warn(string.format("Could not find optional executable: '%s' (%s)", exe, use))
    end
  end

  return true
end

local check_local_config = function()
  local ok, local_config = pcall(require, 'config.local')
  if not ok then
    vim.health.warn "No 'lua/config/local.lua' found. Create it for your Obsidian vault path and AI server URL."
    return
  end

  local notes = local_config.obsidian and local_config.obsidian.notes
  if notes then
    local expanded = vim.fn.expand(notes)
    if vim.fn.isdirectory(expanded) == 1 then
      vim.health.ok(string.format("Obsidian vault found: '%s'", notes))
    else
      vim.health.warn(string.format("Obsidian vault directory not found: '%s'", notes))
    end
  end
end

return {
  check = function()
    vim.health.start 'nvim-config'

    vim.health.info [[NOTE: Not every warning is a 'must-fix' in `:checkhealth`

  Fix only warnings for plugins and languages you intend to use.
    Mason will give warnings for languages that are not installed.
    You do not need to install, unless you want to use those languages!]]

    if vim.g.is_nixos then
      vim.health.info 'NixOS detected: Mason is skipped. Install LSP servers, linters, and formatters as system packages.'
    end

    local uv = vim.uv or vim.loop
    vim.health.info('System Information: ' .. vim.inspect(uv.os_uname()))

    check_version()
    check_external_reqs()
    check_local_config()
  end,
}
