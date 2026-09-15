-- Fidget: LSP progress spinner + notification UI.
-- Notification overrides are left off so the custom notify system in
-- config/notify.lua keeps ownership of vim.notify.
require('fidget').setup {
  notification = {
    override_vim_notify = false,
    window = {
      max_width = 0, -- disable width limit of message
    },
  },
  opts = {
    progress = {
      ignore_empty_message = true,
    },
  },
}
