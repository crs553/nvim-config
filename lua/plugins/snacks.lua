vim.pack.add({
  { src = "https://github.com/folke/snacks.nvim" },
})

require("snacks").setup({
  bigfile = { enabled = true },
  dashboard = {
    enabled = true,
    preset = {
      header = [[
      ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
      ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
      ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
      ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
      ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
      ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝]],
    },
    opts = {
      hide = { statusline = false },
    },
    formats = {
      header = { align = "center" },
      key = function(item)
        return {
          { "[",      hl = "Special" },
          { item.key, hl = "Identifier" },
          { "]",      hl = "Special" },
        }
      end,
    },
    sections = {
      { section = "header" },
      { section = "keys", gap = 1, padding = 1 },
      { pane = 2, icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = 1 },
      { pane = 2, icon = " ", title = "Projects", section = "projects", indent = 2, padding = 1 },
      { pane = 2, height = 16, section = "terminal", cmd = fortune, padding = 1 },
    },
  },
  explorer = { enabled = true },
  indent = { enabled = true },
  input = { enabled = true },
  notifier = { enabled = true, timeout = 3000 },
  picker = { enabled = true },
  quickfile = { enabled = true },
  scope = { enabled = true },
  scroll = { enabled = true },
  statuscolumn = { enabled = true },
  words = { enabled = true },
  styles = { notification = { wo = { wrap = true } } },
})

-- Keymaps
local S = require("snacks")

-- Top Pickers & Explorer
vim.keymap.set("n", "<leader>,", function()
  S.picker.buffers()
end, { desc = "Buffers" })
vim.keymap.set("n", "<leader>:", function()
  S.picker.command_history()
end, { desc = "Command History" })
vim.keymap.set("n", "<leader>n", function()
  S.picker.notifications()
end, { desc = "Notification History" })
vim.keymap.set("n", "<leader>e", function()
  S.explorer()
end, { desc = "File Explorer" })

-- Find
vim.keymap.set("n", "<leader>fb", function()
  S.picker.buffers()
end, { desc = "Buffers" })
vim.keymap.set("n", "<leader>fc", function()
  S.picker.files({ cwd = vim.fn.stdpath("config") })
end, { desc = "Find Config File" })
vim.keymap.set("n", "<leader>fd", function()
  S.picker.files()
end, { desc = "Find Files" })
vim.keymap.set("n", "<leader>fg", function()
  S.picker.git_files()
end, { desc = "Find Git Files" })
vim.keymap.set("n", "<leader>fp", function()
  S.picker.projects()
end, { desc = "Projects" })
vim.keymap.set("n", "<leader>fr", function()
  S.picker.recent()
end, { desc = "Recent" })
vim.keymap.set("n", "<leader>fs", function()
  S.picker.grep()
end, { desc = "Grep" })
vim.keymap.set("n", "<leader>fh", function()
  S.picker.help()
end, { desc = "Help Pages" })

-- Git
vim.keymap.set("n", "<leader>gb", function()
  S.picker.git_branches()
end, { desc = "Git Branches" })
vim.keymap.set("n", "<leader>gl", function()
  S.picker.git_log()
end, { desc = "Git Log" })
vim.keymap.set("n", "<leader>gL", function()
  S.picker.git_log_line()
end, { desc = "Git Log Line" })
vim.keymap.set("n", "<leader>gs", function()
  S.picker.git_status()
end, { desc = "Git Status" })
vim.keymap.set("n", "<leader>gS", function()
  S.picker.git_stash()
end, { desc = "Git Stash" })
vim.keymap.set("n", "<leader>gd", function()
  S.picker.git_diff()
end, { desc = "Git Diff (Hunks)" })
vim.keymap.set("n", "<leader>gf", function()
  S.picker.git_log_file()
end, { desc = "Git Log File" })

-- Grep/Search
vim.keymap.set("n", "<leader>sb", function()
  S.picker.lines()
end, { desc = "Buffer Lines" })
vim.keymap.set("n", "<leader>sB", function()
  S.picker.grep_buffers()
end, { desc = "Grep Open Buffers" })
vim.keymap.set({ "n", "x" }, "<leader>sw", function()
  S.picker.grep_word()
end, { desc = "Visual selection or word" })
vim.keymap.set("n", '<leader>s"', function()
  S.picker.registers()
end, { desc = "Registers" })
vim.keymap.set("n", "<leader>s/", function()
  S.picker.search_history()
end, { desc = "Search History" })
vim.keymap.set("n", "<leader>sa", function()
  S.picker.autocmds()
end, { desc = "Autocmds" })

-- LSP
vim.keymap.set("n", "gd", function()
  S.picker.lsp_definitions()
end, { desc = "Goto Definition" })
vim.keymap.set("n", "gD", function()
  S.picker.lsp_declarations()
end, { desc = "Goto Declaration" })
vim.keymap.set("n", "gr", function()
  S.picker.lsp_references()
end, { nowait = true, desc = "References" })
vim.keymap.set("n", "gI", function()
  S.picker.lsp_implementations()
end, { desc = "Goto Implementation" })
vim.keymap.set("n", "gy", function()
  S.picker.lsp_type_definitions()
end, { desc = "Goto T[y]pe Definition" })
vim.keymap.set("n", "<leader>ss", function()
  S.picker.lsp_symbols()
end, { desc = "LSP Symbols" })
vim.keymap.set("n", "<leader>sS", function()
  S.picker.lsp_workspace_symbols()
end, { desc = "LSP Workspace Symbols" })

-- Other
vim.keymap.set("n", "<leader>z", function()
  S.zen()
end, { desc = "Toggle Zen Mode" })
vim.keymap.set("n", "<leader>.", function()
  S.scratch()
end, { desc = "Toggle Scratch Buffer" })
vim.keymap.set("n", "<leader>S", function()
  S.scratch.select()
end, { desc = "Select Scratch Buffer" })
vim.keymap.set("n", "<leader>bd", function()
  S.bufdelete()
end, { desc = "Delete Buffer" })
vim.keymap.set("n", "<leader>cR", function()
  S.rename.rename_file()
end, { desc = "Rename File" })
vim.keymap.set({ "n", "v" }, "<leader>gB", function()
  S.gitbrowse()
end, { desc = "Git Browse" })
vim.keymap.set("n", "<leader>gg", function()
  S.lazygit()
end, { desc = "Lazygit" })
vim.keymap.set("n", "<leader>un", function()
  S.notifier.hide()
end, { desc = "Dismiss All Notifications" })
vim.keymap.set("n", "<c-_>", function()
  S.terminal()
end, { desc = "which_key_ignore" })
vim.keymap.set({ "n", "t" }, "]]", function()
  S.words.jump(vim.v.count1)
end, { desc = "Next Reference" })
vim.keymap.set({ "n", "t" }, "[[", function()
  S.words.jump(-vim.v.count1)
end, { desc = "Prev Reference" })
vim.keymap.set("n", "<leader>N", function()
  S.win({
    file = vim.api.nvim_get_runtime_file("doc/news.txt", false)[1],
    width = 0.6,
    height = 0.6,
    wo = { spell = false, wrap = false, signcolumn = "yes", statuscolumn = " ", conceallevel = 3 },
  })
end, { desc = "Neovim News" })

-- Init / Lazy setup
vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  callback = function()
    _G.dd = function(...)
      S.debug.inspect(...)
    end
    _G.bt = function()
      S.debug.backtrace()
    end
    vim.print = _G.dd

    -- Toggle mappings
    S.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
    S.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
    S.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
    S.toggle.diagnostics():map("<leader>ud")
    S.toggle.line_number():map("<leader>ul")
    S.toggle
    .option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 })
    :map("<leader>uc")
    S.toggle.treesitter():map("<leader>uT")
    S.toggle.option("background", { off = "light", on = "dark", name = "Dark Background" }):map("<leader>ub")
    S.toggle.inlay_hints():map("<leader>uh")
    S.toggle.indent():map("<leader>ug")
    S.toggle.dim():map("<leader>uD")
  end,
})
