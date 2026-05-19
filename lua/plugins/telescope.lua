local hooks = function(ev)
	local name, kind = ev.data.spec.name, ev.data.kind
	if name == "telescope-fzf-native.nvim" and (kind == "install" or kind == "update") then
		vim.notify("Building telescope-fzf")
		vim.system({ "make" }, { cwd = ev.data.path }):wait()
		vim.notify("Built telescope-fzf")
	end
end
vim.api.nvim_create_autocmd("PackChanged", { callback = hooks })

vim.pack.add({
	"https://github.com/nvim-lua/plenary.nvim",
	"https://github.com/nvim-telescope/telescope.nvim",
	"https://github.com/nvim-telescope/telescope-fzf-native.nvim",
})
local telescope = require("telescope")
local actions = require("telescope.actions")
local actions_layout = require("telescope.actions.layout")
local builtin = require("telescope.builtin")
local themes = require("telescope.themes")

telescope.setup({
	defaults = {
		prompt_prefix = "    ",
		selection_caret = "  ",
		entry_prefix = "  ",

		initial_mode = "insert",
		sorting_strategy = "ascending",

		layout_strategy = "flex",
		layout_config = {
			horizontal = {
				prompt_position = "top",
				preview_width = 0.55,
				width = 0.90,
				height = 0.85,
			},
			vertical = {
				prompt_position = "top",
				width = 0.90,
				height = 0.90,
				preview_height = 0.55,
			},
			flex = {
				flip_columns = 120,
			},
		},

		border = true,
		borderchars = {
			"─",
			"│",
			"─",
			"│",
			"╭",
			"╮",
			"╯",
			"╰",
		},

		winblend = 0,

		file_ignore_patterns = {
			"node_modules",
			".git/",
			"dist/",
			"build/",
			"__pycache__/",
		},

		mappings = {
			i = {
				["<C-j>"] = actions.move_selection_next,
				["<C-k>"] = actions.move_selection_previous,

				["<C-u>"] = false,
				["<C-d>"] = false,

				["<C-p>"] = actions_layout.toggle_preview,

				["<Esc>"] = actions.close,
			},

			n = {
				["q"] = actions.close,
			},
		},
	},

	pickers = {
		find_files = {
			hidden = true,
			follow = true,
			theme = "dropdown",
		},

		git_files = {
			theme = "dropdown",
			show_untracked = true,
		},

		buffers = {
			theme = "dropdown",
			previewer = false,
			sort_lastused = true,
		},

		command_history = {
			theme = "dropdown",
		},

		help_tags = {
			theme = "dropdown",
		},

		live_grep = {
			additional_args = function()
				return { "--hidden" }
			end,
		},
	},

	extensions = {
		fzf = {
			fuzzy = true,
			override_generic_sorter = true,
			override_file_sorter = true,
			case_mode = "smart_case",
		},
	},
})
require("telescope").load_extension("fzf")

-- helpers
local function config_dir()
	return vim.fn.stdpath("config")
end

-- Core setup (you already had this; keeping it compatible)
telescope.setup({
	defaults = {
		sorting_strategy = "ascending",
		layout_config = {
			prompt_position = "top",
		},
		mappings = {
			i = {
				["<C-j>"] = actions.move_selection_next,
				["<C-k>"] = actions.move_selection_previous,
				["<C-q>"] = actions.send_to_qflist,
				["<Esc>"] = actions.close,
			},
		},
	},
})

---------------------------------------------------------------------
-- PICKERS (Snacks → Telescope equivalents)
---------------------------------------------------------------------

local map = vim.keymap

-- Command history
map.set("n", "<leader>:", builtin.command_history, { desc = "Command History" })

-- Notifications (no native telescope equivalent → use messages)
map.set("n", "<leader>fn", function()
	vim.cmd("messages")
end, { desc = "Find Notification History" })

-- Buffers
map.set("n", "<leader>fb", function()
	builtin.buffers(themes.get_dropdown({
		previewer = false,
		sort_mru = true,
	}))
end, { desc = "Buffers" })

-- Config files
map.set("n", "<leader>fc", function()
	builtin.find_files({
		cwd = config_dir(),
	})
end, { desc = "Find Config File" })

-- Files
map.set("n", "<leader>fd", builtin.find_files, { desc = "Find Files" })

-- Git files
map.set("n", "<leader>fg", builtin.git_files, { desc = "Find Git Files" })

-- Projects (closest equivalent: find directories via fd fallback)
map.set("n", "<leader>fp", function()
	builtin.find_files({
		hidden = true,
		no_ignore = true,
	})
end, { desc = "Projects (file-based)" })

-- Recent files
map.set("n", "<leader>fr", builtin.oldfiles, { desc = "Recent" })

-- Grep
map.set("n", "<leader>fs", builtin.live_grep, { desc = "Grep" })

-- Help
map.set("n", "<leader>fh", builtin.help_tags, { desc = "Help Pages" })

-- Grep open buffers
map.set("n", "<leader>fob", function()
	builtin.grep_string({
		search = "",
		grep_open_files = true,
	})
end, { desc = "Search in open buffers" })

-- Keymaps
map.set("n", "<leader>fk", builtin.keymaps, { desc = "Search Keymaps" })

---------------------------------------------------------------------
-- GIT (Telescope native equivalents)
---------------------------------------------------------------------

map.set("n", "<leader>gb", builtin.git_branches, { desc = "Git Branches" })
map.set("n", "<leader>gl", builtin.git_commits, { desc = "Git Log" })

map.set("n", "<leader>gL", function()
	builtin.git_bcommits()
end, { desc = "Git Log Line" })

map.set("n", "<leader>gs", builtin.git_status, { desc = "Git Status" })

map.set("n", "<leader>gS", function()
	vim.cmd("Git stash") -- fallback (Telescope doesn't have stash picker built-in)
end, { desc = "Git Stash" })

map.set("n", "<leader>gd", builtin.git_bcommits, { desc = "Git Diff (Hunks via commits)" })

map.set("n", "<leader>gf", function()
	builtin.git_bcommits({
		bufnr = vim.api.nvim_get_current_buf(),
	})
end, { desc = "Git Log File" })
---------------------------------------------------------------------
-- SEARCH / GREP
---------------------------------------------------------------------

map.set("n", "<leader>sb", builtin.current_buffer_fuzzy_find, { desc = "Buffer Lines" })

map.set("n", "<leader>sB", function()
	builtin.grep_string({
		search = "",
		grep_open_files = true,
	})
end, { desc = "Grep Open Buffers" })

map.set({ "n", "x" }, "<leader>sw", builtin.grep_string, { desc = "Visual selection or word" })

map.set("n", '<leader>s"', builtin.registers, { desc = "Registers" })

map.set("n", "<leader>s/", builtin.search_history, { desc = "Search History" })

map.set("n", "<leader>sa", builtin.autocommands, { desc = "Autocmds" })

---------------------------------------------------------------------
-- LSP (Telescope builtins)
---------------------------------------------------------------------
local function map_lsp(telescope_fn, fallback)
	return function()
		local ok = pcall(function()
			builtin[telescope_fn]()
		end)

		if not ok then
			fallback()
		end
	end
end
map.set("n", "grd", map_lsp("lsp_definitions", vim.lsp.buf.definition), { desc = "Goto Definition" })

map.set("n", "grD", map_lsp("lsp_declarations", vim.lsp.buf.declaration), { desc = "Goto Declaration" })

map.set("n", "gri", map_lsp("lsp_implementations", vim.lsp.buf.implementation), { desc = "Goto Implementation" })

map.set("n", "gry", map_lsp("lsp_type_definitions", vim.lsp.buf.type_definition), { desc = "Goto Type Definition" })

map.set("n", "grx", map_lsp("lsp_references", vim.lsp.buf.references), { desc = "References", nowait = true })
