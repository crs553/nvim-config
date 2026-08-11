-- Fidget: LSP progress spinner + notification UI.
-- Notification overrides are left off so the custom notify system in
-- config/notify.lua keeps ownership of vim.notify.
require('fidget').setup {
  notification = {
    override_vim_notify = false,
  },
}
