return {
	"MeanderingProgrammer/render-markdown.nvim",
	dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.nvim" }, -- if you use the mini.nvim suite
	---@module 'render-markdown'
	---@type render.md.UserConfig
	opts = {},
	config = function()
		require("render-markdown").setup({
			latex = {
				enabled = true,
				render_modes = true,
				converter = { "latex2text" },
				highlight = "RenderMarkdownMath",
				-- Determines where latex formula is rendered relative to block.
				-- | above  | above latex block                               |
				-- | below  | below latex block                               |
				-- | center | centered with latex block (must be single line) |
				position = "center",
				-- Number of empty lines above latex blocks.
				top_pad = 0,
				-- Number of empty lines below latex blocks.
				bottom_pad = 0,
			},
			completions = {
				lsp = { enabled = true },
			},
		})
	end,
}
