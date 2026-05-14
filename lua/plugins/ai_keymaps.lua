-- lua/plugins/ai_keymaps.lua
-- CodeCompanion keymaps: chat, prompts, and agent operations

local map = vim.keymap.set

-- =========================
-- CHAT
-- =========================
map("n", "<leader>aC", "<cmd>CodeCompanion<CR>", { desc = "Open AI chat", silent = true })
map({ "n", "x", "o" }, "<leader>aa", "<cmd>CodeCompanionActions<CR>", { desc = "AI actions", silent = true })
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
map({ "x", "o" }, "<leader>ae", function()
	require("codecompanion").prompt("explain")
end, { desc = "Explain selection" })
map({ "x", "o" }, "<leader>ad", function()
	require("codecompanion").prompt("docs")
end, { desc = "Add docstrings" })
map({ "x", "o" }, "<leader>af", function()
	require("codecompanion").prompt("fix")
end, { desc = "Fix code" })
map({ "x", "o" }, "<leader>ai", function()
	require("codecompanion").prompt("inline")
end, { desc = "Inline prompt" })
map({ "x", "o" }, "<leader>ar", function()
	require("codecompanion").prompt("review")
end, { desc = "Review code" })
map({ "x", "o" }, "<leader>ao", function()
	require("codecompanion").prompt("optimize")
end, { desc = "Optimize code" })
map({ "x", "o" }, "<leader>aR", function()
	require("codecompanion").prompt("refactor")
end, { desc = "Refactor code" })
map({ "x", "o" }, "<leader>at", function()
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
map("n", "<leader>aA", function()
	return require("codecompanion").cli({ prompt = true })
end, { desc = "Prompt the CLI agent" })

-- [C]odeCompanion [A]dd
map({ "n", "v" }, "<leader>aca", function()
	return require("codecompanion").cli("#{this}", { focus = false })
end, { desc = "Add context to the CLI agent" })

-- [C]odeCompanion [D]iagnostics
map("n", "<leader>acd", function()
	return require("codecompanion").cli("#{diagnostics} Can you fix these?", { focus = false, submit = true })
end, { desc = "Send diagnostics to CLI agent" })

-- [C]odeCompanion [T]erminal
map("n", "<leader>dct", function()
	return require("codecompanion").cli(
		"#{terminal} Sharing the output from the terminal. Can you fix it?",
		{ focus = false, submit = true }
	)
end, { desc = "Send terminal output to CLI agent" })
