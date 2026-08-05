-- Zero-dependency deferred setup helper.
-- Heavier plugin `setup()` calls are queued and run once, after startup,
-- via the `VeryLazy` event (fired by init.lua through `vim.schedule`).
local M = {}

local fired = false
local queue = {}

local function run_queue()
  local pending = queue
  queue = nil
  for _, fn in ipairs(pending) do
    local ok, err = pcall(fn)
    if not ok then vim.notify(('Deferred setup error: %s'):format(err), vim.log.levels.ERROR) end
  end
end

--- Defer `fn` until the `VeryLazy` event fires (after startup).
--- Runs immediately if `VeryLazy` already fired.
---@param fn function
function M.setup(fn)
  if fired then
    fn()
    return
  end
  table.insert(queue, fn)
end

--- Defer `fn` until the first occurrence of `events`.
---@param events string|string[]
---@param fn function
function M.on(events, fn) vim.api.nvim_create_autocmd(events, { once = true, callback = fn }) end

--- Fire the `VeryLazy` event (idempotent). Deferred setups run first.
function M.fire()
  if fired then return end
  fired = true
  run_queue()
  vim.api.nvim_exec_autocmds('User', { pattern = 'VeryLazy' })
end

return M
