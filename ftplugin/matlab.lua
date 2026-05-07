-- ============================================================
-- MATLAB Filetype Configuration
-- Sections: Settings | Section Navigation | Code Execution
-- ============================================================

local lopt = vim.opt_local
local map = vim.keymap.set
local buf = 0

-- ============================================================
-- 1. Editor Settings
-- ============================================================

lopt.commentstring = "% %s"
lopt.tabstop = 4
lopt.shiftwidth = 4
lopt.expandtab = true

-- Fold by %% section markers (MATLAB cells)
lopt.foldmethod = "expr"
lopt.foldexpr = [[getline(v:lnum) =~ '^\s*%%' ? '>1' : '=']]
lopt.foldenable = true
lopt.foldlevel = 99

-- ============================================================
-- 2. Section Navigation (%% cells)
-- ============================================================

map("n", "[%", function()
	vim.fn.search("^\\s*%%", "bW")
end, { buffer = buf, desc = "MATLAB: prev section" })

map("n", "]%", function()
	vim.fn.search("^\\s*%%", "W")
end, { buffer = buf, desc = "MATLAB: next section" })

-- ============================================================
-- 3. Code Execution (via matlab -batch)
-- ============================================================

local function run_batch(filepath)
	vim.cmd("!" .. 'matlab -batch "run(' .. "'" .. filepath .. "'" .. ')"')
end

-- Helper: extract current %% section boundaries
local function section_range()
	local cursor = vim.api.nvim_win_get_cursor(0)
	local cl = cursor[1]
	local total = vim.api.nvim_buf_line_count(0)

	local sline = 1
	for l = cl - 1, 1, -1 do
		local text = vim.api.nvim_buf_get_lines(0, l - 1, l, false)[1]
		if text and text:match("^%%") then
			sline = l + 1
			break
		end
	end

	local eline = total
	for l = cl + 1, total do
		local text = vim.api.nvim_buf_get_lines(0, l - 1, l, false)[1]
		if text and text:match("^%%") then
			eline = l - 1
			break
		end
	end

	return sline, eline
end

local function run_lines(lines)
	local tmp = vim.fn.tempname() .. ".m"
	vim.fn.writefile(lines, tmp)
	run_batch(tmp)
end

-- <leader>mr: Run current file
map("n", "<leader>mr", function()
	run_batch(vim.fn.expand("%:p"))
end, { buffer = buf, desc = "MATLAB: run file" })

-- <leader>mc: Run current %% section
map("n", "<leader>mc", function()
	local sline, eline = section_range()
	if sline > eline then
		return
	end
	run_lines(vim.api.nvim_buf_get_lines(0, sline - 1, eline, false))
end, { buffer = buf, desc = "MATLAB: run section" })

-- <leader>ml: Run current line
map("n", "<leader>ml", function()
	local line = vim.api.nvim_get_current_line()
	run_lines({ line })
end, { buffer = buf, desc = "MATLAB: run line" })

-- <leader>ms: Run visual selection
map("v", "<leader>ms", function()
	run_lines(vim.fn.getline("'<", "'>"))
end, { buffer = buf, desc = "MATLAB: run selection" })

-- ============================================================
-- 4. Snippets
-- ============================================================

local ok, ls = pcall(require, "luasnip")
if ok then
	local s = ls.snippet
	local t = ls.text_node
	local i = ls.insert_node

	ls.add_snippets("matlab", {
		s("fun", {
			t({ "function [" }),
			i(1),
			t({ "] = " }),
			i(2),
			t({ "(" }),
			i(3),
			t({ ")" }),
			t({ "", "\t" }),
			i(0),
			t({ "", "end" }),
		}),
		s("if", {
			t({ "if " }),
			i(1),
			t({ "", "\t" }),
			i(0),
			t({ "", "end" }),
		}),
		s("ife", {
			t({ "if " }),
			i(1),
			t({ "", "\t" }),
			i(2),
			t({ "", "else" }),
			t({ "", "\t" }),
			i(0),
			t({ "", "end" }),
		}),
		s("for", {
			t({ "for " }),
			i(1),
			t({ " = " }),
			i(2),
			t({ "", "\t" }),
			i(0),
			t({ "", "end" }),
		}),
		s("while", {
			t({ "while " }),
			i(1),
			t({ "", "\t" }),
			i(0),
			t({ "", "end" }),
		}),
		s("switch", {
			t({ "switch " }),
			i(1),
			t({ "", "\tcase " }),
			i(2),
			t({ "", "\t\t" }),
			i(0),
			t({ "", "end" }),
		}),
		s("try", {
			t({ "try" }),
			t({ "", "\t" }),
			i(1),
			t({ "", "catch " }),
			i(2),
			t({ "", "\t" }),
			i(0),
			t({ "", "end" }),
		}),
		s("parfor", {
			t({ "parfor " }),
			i(1),
			t({ " = " }),
			i(2),
			t({ "", "\t" }),
			i(0),
			t({ "", "end" }),
		}),
		s("spmd", {
			t({ "spmd" }),
			t({ "", "\t" }),
			i(0),
			t({ "", "end" }),
		}),
		s("class", {
			t({ "classdef " }),
			i(1),
			t({ "", "", "\tproperties" }),
			t({ "", "\t\t" }),
			i(2),
			t({ "", "\tend" }),
			t({ "", "", "\tmethods" }),
			t({ "", "\t\tfunction " }),
			i(3),
			t({ "", "\t\t\t" }),
			i(0),
			t({ "", "\t\tend" }),
			t({ "", "\tend" }),
			t({ "", "end" }),
		}),
		s("disp", {
			t({ "disp(" }),
			i(1),
			t({ ")" }),
		}),
		s("plot", {
			t({ "figure; plot(" }),
			i(1),
			t({ ", " }),
			i(2),
			t({ ")" }),
			t({ "", "xlabel('" }),
			i(3),
			t({ "')" }),
			t({ "", "ylabel('" }),
			i(4),
			t({ "')" }),
			t({ "", "title('" }),
			i(5),
			t({ "')" }),
			t({ "", "grid on" }),
		}),
		s("fplot", {
			t({ "figure; fplot(@(" }),
			i(1),
			t({ ") " }),
			i(2),
			t({ ", [" }),
			i(3),
			t({ "]);" }),
			t({ "", "xlabel('" }),
			i(4),
			t({ "')" }),
			t({ "", "ylabel('" }),
			i(5),
			t({ "')" }),
			t({ "", "title('" }),
			i(6),
			t({ "')" }),
			t({ "", "grid on" }),
		}),
	})
end
