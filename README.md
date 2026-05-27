# nvim-config

Personal Neovim configuration using `vim.pack` (Neovim 0.11+).

## Required file

To keep machine-specific paths out of version control, create `lua/config/local.lua`:

```lua
return {
  obsidian = {
    notes = "~/notes",
  },
  ai = {
    lmstudio_url = "http://192.168.17.152:1234",
  },
}
```

Fields:

| Field             | Purpose                                                   |
| ----------------- | --------------------------------------------------------- |
| `obsidian.notes`  | Path to your Obsidian vault                               |
| `ai.lmstudio_url` | URL of your LM Studio (or other OpenAI-compatible) server |

The config falls back to sensible defaults if `local.lua` is missing.

## Testing

### Sanity check

Open Neovim and run:

```
:checkhealth
```

Verify no errors for key plugins (lspconfig, treesitter, telescope, etc.).

### LSP

Open a Lua file and run:

```
:LspInfo
```

Confirm `lua_ls` is attached.

### Formatter

```
:lua require("conform").format()
```

### Notifications

```
:lua vim.notify("hello world", vim.log.levels.INFO)
:lua vim.notify("something went wrong", vim.log.levels.ERROR)
:lua vim.notify("be careful", vim.log.levels.WARN)
```

View history with `<leader>uN`, dismiss with `<leader>un`.

### Mason (non-NixOS)

```
:Mason
```

Verify servers/linters are installed.

### NixOS

On NixOS, Mason is skipped automatically. Ensure system packages are installed for:

- `lua-language-server` (Lua LSP)
- `stylua` (Lua formatter)
- `rust-analyzer` (Rust LSP)
- `marksman` (Markdown LSP)
- Any other tools from `ensure_installed`

### Full plugin list

All specs are in `lua/plugins/`. To verify a plugin loaded:

```
:lua print(vim.fn.exists("##User") and "loaded" or "missing")
```

Or check with `:lua print(vim.pack.get("plugin-name"))`.
