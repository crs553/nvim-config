return {
  "tpope/vim-fugitive",

  keys = {
    { "<leader>gs", vim.cmd.Git, desc = "Git Status" },
    { "<leader>gd", vim.cmd.Gvdiffsplit, desc = "Git Diff Split" },
  },
}
