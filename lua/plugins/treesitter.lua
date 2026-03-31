return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  build = ":TSUpdate", -- Always keep parsers up to date

  event = { "BufReadPost", "BufNewFile" },

  opts = {
    highlight = { enable = true },
    indent = { enable = true },
    ensure_installed = {
      -- "all" installs everything, but it's heavy; better to specify
      "bash",
      "c",
      "cmake",
      "cpp",
      "css",
      "diff",
      "gitignore",
      "html",
      "java",
      "javascript",
      "json",
      "latex",
      "lua",
      "markdown",
      "markdown_inline",
      "matlab",
      "python",
      "query",
      "regex",
      "rust",
      "toml",
      "tsx",
      "typescript",
      "vim",
      "vimdoc",
      "yaml",
    },
  },
}
