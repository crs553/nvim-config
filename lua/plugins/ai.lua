local lazy = require 'config.lazy'

lazy.setup(function()
  require('mini.diff').setup()

  require('codecompanion').setup {
    adapters = {
      acp = {
        opencode = function()
          return require('codecompanion.adapters').extend('opencode', {
            command = {
              default = {
                'opencode',
                'acp',
              },
            },
            model = 'qwen/qwen3.5-9b',
          })
        end,
      },
      http = {
        lmstudio = function()
          return require('codecompanion.adapters').extend('openai_compatible', {
            name = 'lmstudio',

            env = {
              url = (function()
                local ok, local_config = pcall(require, 'config.local')
                return (ok and local_config.ai and local_config.ai.lmstudio_url)
                  or 'http://localhost:1234'
              end)(),
              api_key = 'lmstudio',
            },

            schema = {
              model = {
                default = 'qwen/qwen3.5-9b',
              },
            },

            stream = true,
          })
        end,
      },
    },

    interactions = {
      cli = {
        agent = 'open_code',
        agents = {
          open_code = {
            cmd = 'opencode',
            description = 'Open Opencode CLI',
            provider = 'terminal',
            auto_insert = true, -- Enter insert mode when focusing the CLI terminal
            reload = true, -- Reload buffers when an agent modifies files on disk
          },
        },
      },
      cmd = { adapter = 'lmstudio' },
      chat = {
        adapter = 'lmstudio',
        auto_apply = false,
        icons = {
          chat_context = '💬', -- You can also apply an icon to the fold
          chat_fold = ' ',
        },
        fold_context = true,
        fold_reasoning = false,
        opts = {
          completion_provider = 'default',
        },
        show_reasoning = false,
      },
      inline = {
        adapter = 'lmstudio',
        keymaps = {
          accept = '<leader>ya',
          reject = '<leader>yr',
        },
      },
      agent = {
        adapter = 'opencode',
      },
      background = {
        chat = {
          callbacks = {
            ['on_ready'] = {
              actions = {
                'interactions.background.builtin.chat_make_title',
              },
              enabled = true,
            },
          },
          opts = {
            enabled = true,
          },
        },
      },
      opts = {
        date_format = '%A, %d %B %Y',
        log_level = 'INFO',
        language = 'British English',
        per_project_config = {
          files = {
            '.codecompanion.lua',
          },
        },
        test_mode = false,
      },
    },

    display = {
      action_palette = {
        provider = 'snacks',
      },
      diff = {
        provider = 'mini_diff',
      },
    },

    prompt_library = {
      markdown = {
        dirs = {
          vim.fn.getcwd() .. '/.prompts',
          '~/.dotfiles/.config/prompts',
        },
      },
    },
  }
end)

vim.api.nvim_create_autocmd('User', {
  pattern = 'CodeCompanionChatCreated',
  callback = function(args)
    local chat = require('codecompanion').buf_get_chat(args.data.bufnr)
    chat:add_callback('on_checkpoint', function(_, data)
      local context_window = data.adapter.meta and data.adapter.meta.context_window
      if not context_window then return end

      local usage = data.estimated_tokens / context_window
      if usage > 0.8 then
        vim.notify(string.format('Context window %.0f%% full', usage * 100), vim.log.levels.WARN)
        -- Compact data.messages in-place here
      end
    end)
  end,
})

require 'plugins.ai_keymaps'
vim.cmd [[cab cc CodeCompanion]]
