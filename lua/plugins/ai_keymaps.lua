-- lua/plugins/ai_keymaps.lua
-- CodeCompanion keymaps: chat, prompts, and agent operations

local map = vim.keymap.set

-- =========================
-- CHAT
-- =========================
map("n", "<leader>ac", "<cmd>CodeCompanionToggle<CR>", { desc = "Toggle AI chat", silent = true })
map("n", "<leader>aC", "<cmd>CodeCompanion<CR>", { desc = "Open AI chat", silent = true })
map({ "n", "v" }, "<leader>aa", "<cmd>CodeCompanionActions<CR>", { desc = "AI actions", silent = true })
map("n", "<leader>as", vim.cmd.CodeCompanionStop, { desc = "Stop AI", silent = true })

-- =========================
-- AGENT & BACKGROUND
-- =========================
map("n", "<leader>aA", function()
	require("codecompanion").prompt("agent")
end, { desc = "Agent mode" })
map("n", "<leader>ab", function()
	require("codecompanion").prompt("background")
end, { desc = "Background chat" })

-- =========================
-- VISUAL SELECTION PROMPTS
-- =========================
map("v", "<leader>ae", function()
	require("codecompanion").prompt("explain")
end, { desc = "Explain selection" })
map("v", "<leader>ad", function()
	require("codecompanion").prompt("docs")
end, { desc = "Add docstrings" })
map("v", "<leader>af", function()
	require("codecompanion").prompt("fix")
end, { desc = "Fix code" })
map("v", "<leader>ai", function()
	require("codecompanion").prompt("inline")
end, { desc = "Inline prompt" })
map("v", "<leader>ar", function()
	require("codecompanion").prompt("review")
end, { desc = "Review code" })
map("v", "<leader>ao", function()
	require("codecompanion").prompt("optimize")
end, { desc = "Optimize code" })
map("v", "<leader>aR", function()
	require("codecompanion").prompt("refactor")
end, { desc = "Refactor code" })
map("v", "<leader>at", function()
	require("codecompanion").prompt("translate")
end, { desc = "Translate code" })

-- =========================
-- NORMAL MODE BUFFER/GIT PROMPTS
-- =========================
map("n", "<leader>aE", function()
	require("codecompanion").prompt("explainbuf")
end, { desc = "Explain buffer" })
map("n", "<leader>aD", function()
	require("codecompanion").prompt("docsgen")
end, { desc = "Generate project docs" })
map("n", "<leader>ag", function()
	require("codecompanion").prompt("commit")
end, { desc = "Generate commit message" })
map("n", "<leader>ap", function()
	require("codecompanion").prompt("pr")
end, { desc = "Generate PR description" })
