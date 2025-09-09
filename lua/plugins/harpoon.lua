return {
  "theprimeagen/harpoon",
  branch = "harpoon2",

  dependencies = {
    "nvim-lua/plenary.nvim",
  },

  ---@type harpoon.Config
  opts = {
    settings = {
      save_on_toggle = true,
    },
  },

  keys = function()
    local harpoon = require("harpoon")

    return {
      -- open & add functions
      { "<leader>A", function() harpoon:list():prepend() end, desc = "Harpoon Prepend" },
      { "<leader>a", function() harpoon:list():add() end, desc = "Harpoon Add" },
      { "<C-e>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, desc = "Harpoon Quick Menu" },

      -- switching functions
      { "<C-h>", function() harpoon:list():select(1) end, desc = "Harpoon to 1" },
      { "<C-j>", function() harpoon:list():select(2) end, desc = "Harpoon to 2" },
      { "<C-k>", function() harpoon:list():select(3) end, desc = "Harpoon to 3" },
      { "<C-l>", function() harpoon:list():select(4) end, desc = "Harpoon to 4" },

      -- replacing functions
      { "<leader><C-h>", function() harpoon:list():replace_at(1) end, desc = "Harpoon Replace 1" },
      { "<leader><C-j>", function() harpoon:list():replace_at(2) end, desc = "Harpoon Replace 2" },
      { "<leader><C-k>", function() harpoon:list():replace_at(3) end, desc = "Harpoon Replace 3" },
      { "<leader><C-l>", function() harpoon:list():replace_at(4) end, desc = "Harpoon Replace 4" },
    }
  end,
}



