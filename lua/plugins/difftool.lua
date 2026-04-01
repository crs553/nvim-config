vim.cmd("packadd nvim.difftool")
local function diff_current_file()
	local current_file = vim.fn.expand("%:p") -- full path of current buffer
	local target_file = vim.fn.input("Diff with file: ", current_file, "file")
	if target_file ~= "" then
		-- Open diff in nvim.difftool
		vim.cmd("DiffTool " .. current_file .. " " .. target_file)
	else
		print("No file specified for diff.")
	end
end

-- Map <leader>dt to the diff function
vim.keymap.set("n", "<leader>dt", diff_current_file, { noremap = true, silent = true, desc = "Diff Tool Current File" })
