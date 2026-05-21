vim.pack.add({
	{ src = "https://github.com/obsidian-nvim/obsidian.nvim", version = "v3.16.3" },
	"nvim-lua/plenary.nvim",
})

local ok, local_config = pcall(require, "config.local")
local vaults = ok and local_config.obsidian or {}

local notes_path = (vaults.notes and vaults.notes) or vim.fn.expand("~/notes")

require("obsidian").setup({
	workspaces = {
		{
			name = "notes",
			path = notes_path,
		},
	},
})

local map = vim.keymap.set

-- helper: wrap Obsidian commands safely
local obs = function(cmd)
	return function()
		vim.cmd["Obsidian" .. cmd]()
	end
end

-- 📄 Core note actions
map("n", "<leader>on", obs("New"), { desc = "New note" })
map("n", "<leader>oo", obs("Open"), { desc = "Open note in Obsidian app" })
map("n", "<leader>ot", obs("Today"), { desc = "Today's note" })
map("n", "<leader>oy", obs("Yesterday"), { desc = "Yesterday's note" })

-- 🔍 Search / navigation
map("n", "<leader>os", obs("Search"), { desc = "Search notes" })
map("n", "<leader>of", obs("QuickSwitch"), { desc = "Quick switch note" })
map("n", "<leader>ol", obs("FollowLink"), { desc = "Follow link under cursor" })

-- 🔗 Linking
map("n", "<leader>ow", obs("Link"), { desc = "Link selection (wiki link)" })
map("v", "<leader>ow", obs("Link"), { desc = "Link selection" })

map("n", "<leader>oW", obs("LinkNew"), { desc = "Link to new note" })
map("v", "<leader>oW", obs("LinkNew"), { desc = "Link selection to new note" })

-- 🧠 Tags / media / daily workflow
map("n", "<leader>oT", obs("Tags"), { desc = "Search tags" })
map("n", "<leader>op", obs("PasteImg"), { desc = "Paste image into note" })

map("n", "<leader>od", obs("Dailies"), { desc = "Open daily notes" })
map("n", "<leader>oc", obs("Template"), { desc = "Insert template" })
