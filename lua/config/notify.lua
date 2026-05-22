local notify = {}

local history = {}
local ns = vim.api.nvim_create_namespace("notify")
local prefix_width = 18

local level_labels = {
  [vim.log.levels.TRACE] = "TRACE",
  [vim.log.levels.DEBUG] = "DEBUG",
  [vim.log.levels.INFO] = "INFO",
  [vim.log.levels.WARN] = "WARN",
  [vim.log.levels.ERROR] = "ERROR",
}

local border_hl = {
  [vim.log.levels.TRACE] = "DiagnosticInfo",
  [vim.log.levels.DEBUG] = "DiagnosticHint",
  [vim.log.levels.INFO] = "DiagnosticInfo",
  [vim.log.levels.WARN] = "DiagnosticWarn",
  [vim.log.levels.ERROR] = "DiagnosticError",
}

local function wrap(text, width)
  if width < 1 then
    return { "" }
  end
  local lines = {}
  for paragraph in text:gmatch("[^\n]+") do
    while #paragraph > width do
      local break_at = paragraph:sub(1, width):match("^.+%s()")
      break_at = (break_at or width + 1) - 1
      table.insert(lines, paragraph:sub(1, break_at))
      paragraph = paragraph:sub(break_at + 1):match("^%s*(.*)")
    end
    table.insert(lines, paragraph)
  end
  if #lines == 0 then
    lines = { text }
  end
  return lines
end

function notify.notify(msg, level, opts)
  level = level or vim.log.levels.INFO
  opts = opts or {}

  table.insert(history, { msg = msg, level = level, time = os.time(), opts = opts })

  local width = math.min(64, vim.o.columns - 4)
  local wrapped = wrap(msg, width - 2)
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, wrapped)
  vim.api.nvim_buf_set_option(buf, "modifiable", false)
  vim.api.nvim_set_option_value("filetype", "notify", { buf = buf })

  local title = opts.title and (" " .. opts.title .. " ") or (" " .. (level_labels[level] or "INFO") .. " ")
  local hl = border_hl[level] or "DiagnosticInfo"

  local win = vim.api.nvim_open_win(buf, false, {
    relative = "editor",
    width = width,
    height = #wrapped,
    row = 1,
    col = vim.o.columns - width - 1,
    style = "minimal",
    border = "rounded",
    title = title,
    title_pos = "left",
    noautocmd = true,
  })

  vim.api.nvim_set_hl(ns, "NotifyBorder", { link = hl })
  vim.api.nvim_win_set_hl_ns(win, ns)
  vim.api.nvim_win_set_option(win, "winhl", "Normal:NormalFloat,FloatBorder:NotifyBorder")

  local timeout = opts.timeout or 3000
  vim.defer_fn(function()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
    if vim.api.nvim_buf_is_valid(buf) then
      vim.api.nvim_buf_delete(buf, { force = true })
    end
  end, timeout)
end

function notify.dismiss()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local ok_w, config = pcall(vim.api.nvim_win_get_config, win)
    if ok_w and config.relative == "editor" and config.row == 1 then
      local ok_b, ft = pcall(vim.api.nvim_buf_get_option, vim.api.nvim_win_get_buf(win), "filetype")
      if ok_b and ft == "notify" then
        vim.api.nvim_win_close(win, true)
      end
    end
  end
end

function notify.history()
  if #history == 0 then
    vim.notify("No notifications yet", vim.log.levels.INFO)
    return
  end

  local width = math.floor(vim.o.columns * 0.6)
  local height = math.floor(vim.o.lines * 0.6)
  local content_width = width - prefix_width - 3

  local buflines = {}
  local levels = {}
  local labels = { "TRACE", "DEBUG", "INFO", "WARN", "ERROR" }

  for i, entry in ipairs(history) do
    local label = labels[entry.level] or "INFO"
    local time = os.date("%H:%M:%S", entry.time)
    local prefix = string.format("[%s] %s", time, label)
    local wrapped = wrap(entry.msg, content_width)

    levels[i] = entry.level

    for j, wline in ipairs(wrapped) do
      if j == 1 then
        table.insert(buflines, prefix .. "  " .. wline)
      else
        table.insert(buflines, string.rep(" ", prefix_width) .. "  " .. wline)
      end
    end
  end

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, buflines)
  vim.api.nvim_buf_set_option(buf, "modifiable", false)

  local line = 0
  for i = 1, #history do
    local hl = border_hl[levels[i]] or "DiagnosticInfo"
    local nlines = #wrap(history[i].msg, content_width)
    for _ = 1, nlines do
      vim.api.nvim_buf_add_highlight(buf, -1, hl, line, 0, prefix_width)
      line = line + 1
    end
  end

  local win_height = math.min(#buflines, height)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = win_height,
    row = math.floor((vim.o.lines - win_height) / 2) - 1,
    col = math.floor((vim.o.columns - width) / 2),
    style = "minimal",
    border = "rounded",
    title = " Notification History ",
    title_pos = "center",
  })
  vim.keymap.set("n", "<Esc>", function()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end, { buffer = buf, nowait = true, silent = true })
end

vim.notify = notify.notify

vim.keymap.set("n", "<leader>un", function()
	notify.dismiss()
end, { desc = "Dismiss All Notifications" })
vim.keymap.set("n", "<leader>uN", function()
	notify.history()
end, { desc = "Notification History" })

return notify
