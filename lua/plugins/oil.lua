return {
  "stevearc/oil.nvim",
  ---@module 'oil'
  ---@type oil.SetupOpts
  opts = {},
  -- Optional dependencies
  dependencies = { { "nvim-mini/mini.icons", opts = {} } },
  -- dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if you prefer nvim-web-devicons

  -- Lazy loading is not recommended for oil.nvim
  lazy = false,

  keys = {
    { "-", "<CMD>Oil<CR>", desc = "Open parent directory" },
  },
}


