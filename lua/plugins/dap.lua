vim.pack.add({
	{ src = "https://codeberg.org/mfussenegger/nvim-dap.git" },
	{ src = "https://github.com/rcarriga/nvim-dap-ui" },
	{ src = "https://github.com/theHamsta/nvim-dap-virtual-text" },
	{ src = "https://github.com/leoluz/nvim-dap-go" },
	{ src = "https://github.com/mfussenegger/nvim-dap-python" },
	{ src = "https://github.com/nvim-neotest/nvim-nio" },
})

local dap = require("dap")
local dapui = require("dapui")

-- ======================
-- DAP UI Setup
-- ======================
dapui.setup({
	icons = { expanded = "▾", collapsed = "▸", current_frame = "▸" },
	controls = {
		icons = {
			pause = "⏸",
			play = "▶",
			step_into = "⏎",
			step_over = "⏭",
			step_out = "⏮",
			step_back = "⏪",
			run_last = "▶▶",
			terminate = "⏹",
			disconnect = "⏏",
		},
	},
})

-- Auto-open/close DAP UI
dap.listeners.after.event_initialized["dapui"] = function()
	dapui.open({ reset = true })
end
dap.listeners.after.event_terminated["dapui"] = function()
	dapui.close()
end
dap.listeners.after.event_exited["dapui"] = function()
	dapui.close()
end

dap.configurations.go = {
	{
		type = "go",
		name = "Debug current file",
		request = "launch",

		program = "${fileDirname}",
		cwd = "${workspaceFolder}",

		args = {},
	},
}

-- ======================
-- Virtual Text
-- ======================
require("nvim-dap-virtual-text").setup({
	enabled = true,
	virt_text_pos = "eol",
	highlight_changed_variables = true,
	show_stop_reason = true,
})

-- ======================
-- Go DAP (nvim-dap-go)
-- ======================
require("dap-go").setup({
	dap_configurations = {
		{
			type = "go",
			name = "Attach remote",
			mode = "remote",
			request = "attach",
		},
	},
	delve = {
		path = "dlv",
		initialize_timeout_sec = 20,
		port = "${port}",
		args = {},
		build_flags = {},
		detached = vim.fn.has("win32") == 0,
		cwd = nil,
	},
	tests = {
		verbose = false,
	},
})

-- ======================
-- Python DAP (nvim-dap-python)
-- ======================
require("dap-python").setup("python")
-- Resolve python from virtualenvs
_G._python_dap = function()
	local venv_paths = {
		vim.fn.getcwd() .. "/.venv/bin/python",
		vim.fn.getcwd() .. "/venv/bin/python",
		vim.fn.getcwd() .. "/.venv/Scripts/python.exe",
		vim.fn.getcwd() .. "/venv/Scripts/python.exe",
	}
	for _, path in ipairs(venv_paths) do
		if vim.fn.executable(path) == 1 then
			return path
		end
	end
	return "python"
end
vim.cmd([[command! -nargs=* DapPythonSetPython lua require("dap-python").setup(_G._python_dap())]])
vim.cmd([[DapPythonSetPython]])

-- ======================
-- DAP Keymaps
-- ======================
vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "Toggle breakpoint" })
vim.keymap.set("n", "<leader>dB", function()
	dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
end, { desc = "Conditional breakpoint" })
vim.keymap.set("n", "<F5>", dap.continue, { desc = "Continue / Start" })
vim.keymap.set("n", "<leader>dC", dap.run_to_cursor, { desc = "Run to cursor" })
vim.keymap.set("n", "<leader>do", dap.step_over, { desc = "Step over" })
vim.keymap.set("n", "<leader>di", dap.step_into, { desc = "Step into" })
vim.keymap.set("n", "<leader>dO", dap.step_out, { desc = "Step out" })
vim.keymap.set("n", "<leader>dt", dap.terminate, { desc = "Terminate" })
vim.keymap.set("n", "<leader>dr", function()
	dap.repl.toggle({}, "vsplit")
end, { desc = "Toggle REPL" })
vim.keymap.set("n", "<leader>du", dapui.toggle, { desc = "Toggle DAP UI" })
vim.keymap.set("n", "<leader>de", function()
	dapui.eval()
end, { desc = "Evaluate expression (hover)" })
vim.keymap.set({ "x", "o" }, "<leader>de", function()
	dapui.eval()
end, { desc = "Evaluate expression (visual)" })
vim.keymap.set("n", "<leader>dk", dap.up, { desc = "Move up stack frame" })
vim.keymap.set("n", "<leader>dj", dap.down, { desc = "Move down stack frame" })
vim.keymap.set("n", "<leader>dh", function()
	local buf = dapui.elements.stacks.buffer()
	local wins = vim.fn.win_findbuf(buf)
	if #wins > 0 then
		vim.api.nvim_set_current_win(wins[1])
	end
end, { desc = "Focus stacks" })
