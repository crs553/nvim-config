-- TODO/FIXME comment highlighting + finder, implemented natively (no plugin).
--   * highlight: extmarks on comment keywords via the treesitter comment nodes
--   * find     : <leader>ft grep for keywords across the project

local S = require 'snacks'

local ns = vim.api.nvim_create_namespace 'todo_comments'

local groups = {
  TODO = 'TodoFgTODO',
  FIXME = 'TodoFgFIXME',
  HACK = 'TodoFgHACK',
  WARN = 'TodoFgWARN',
  NOTE = 'TodoFgNOTE',
  PERF = 'TodoFgPERF',
  TEST = 'TodoFgTEST',
}

-- Theme-safe: link our groups to the Diagnostic* palette.
local links = {
  TodoFgTODO = 'DiagnosticInfo',
  TodoFgFIXME = 'DiagnosticError',
  TodoFgHACK = 'DiagnosticWarn',
  TodoFgWARN = 'DiagnosticWarn',
  TodoFgNOTE = 'DiagnosticHint',
  TodoFgPERF = 'DiagnosticHint',
  TodoFgTEST = 'DiagnosticHint',
}

local function define_highlights()
  for group, link in pairs(links) do
    vim.api.nvim_set_hl(0, group, { link = link, default = true })
  end
end
define_highlights()

vim.api.nvim_create_autocmd('ColorScheme', { callback = define_highlights })

-- Find known keywords in a comment line. Matches whole uppercase tokens only,
-- so e.g. "TODAY" or "TODOLIST" are skipped.
local function find_keywords(text)
  local res = {}
  local pos = 1
  while true do
    local s, e = text:find('%u[%u%d]*', pos)
    if not s then break end
    local word = text:sub(s, e)
    if groups[word] then
      local prev = s > 1 and text:sub(s - 1, s - 1) or ''
      local nxt = text:sub(e + 1, e + 1) or ''
      if not prev:match '[%w_]' and not nxt:match '[%w_]' then
        res[#res + 1] = { s = s, e = e, group = groups[word] }
      end
    end
    pos = e + 1
  end
  return res
end

local function scan(bufnr)
  vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
  local ok, parser = pcall(vim.treesitter.get_parser, bufnr)
  if not ok or not parser then return end
  local tree = parser:parse()[1]
  if not tree then return end

  local comments = {}
  local function walk(node)
    if node:type():match 'comment' then comments[#comments + 1] = node end
    for child in node:iter_children() do
      walk(child)
    end
  end
  walk(tree:root())

  for _, node in ipairs(comments) do
    local srow, scol, erow = node:range()
    for row = srow, erow do
      local line = vim.api.nvim_buf_get_lines(bufnr, row, row + 1, false)[1]
      if line then
        local start = row == srow and scol or 0
        local text = line:sub(start + 1)
        for _, m in ipairs(find_keywords(text)) do
          vim.api.nvim_buf_set_extmark(bufnr, ns, row, start + m.s - 1, {
            hl_group = m.group,
            end_col = start + m.e,
            priority = 110,
          })
        end
      end
    end
  end
end

local group = vim.api.nvim_create_augroup('todo_comments', { clear = true })
vim.api.nvim_create_autocmd({ 'BufReadPost', 'BufWritePost' }, {
  group = group,
  callback = function(ev)
    if vim.api.nvim_buf_get_name(ev.buf) == '' then return end
    if not vim.bo[ev.buf].modifiable then return end
    vim.schedule(function()
      if vim.api.nvim_buf_is_valid(ev.buf) then scan(ev.buf) end
    end)
  end,
})

vim.keymap.set(
  'n',
  '<leader>ft',
  function() S.picker.grep { pattern = '\\b(TODO|FIXME|HACK|WARN|NOTE|PERF|TEST)\\b' } end,
  { desc = 'Find TODOs' }
)
