return {
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy", -- lazy-load after startup
    dependencies = { "nvim-tree/nvim-web-devicons" }, -- optional, for icons
    config = function()
      require("lualine").setup({
        options = {
          theme = "auto",
          section_separators = { left = "", right = "" },
          component_separators = { left = "", right = "" },
          globalstatus = true, -- if using Neovim 0.8+
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch", "diff", "diagnostics" },
          lualine_c = { "filename" },
          lualine_x = { "encoding", "fileformat", "filetype" },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
      })
    end,
  },
}

