local S = require 'snacks'

local sections = { '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', 'n', 'l' }

vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'help', 'man' },
  callback = function(args)
    -- Open in vertical split
    vim.cmd 'wincmd L'

    -- Winbar: show man page name
    local name = vim.api.nvim_buf_get_name(args.buf)
    local page = name:match '/([^/]+)%.' or name
    vim.wo.winbar = ' ' .. page

    -- <leader>mk: Man page for word, falls back to :help
    vim.keymap.set('n', '<leader>mk', function()
      local word = vim.fn.expand '<cword>'
      local ok = pcall(vim.cmd, 'Man ' .. word)
      if not ok then vim.cmd('help ' .. word) end
    end, { buffer = args.buf, desc = 'Man page (fallback to help)' })

    -- <leader>mq: Close man page
    vim.keymap.set('n', '<leader>mq', '<cmd>close<CR>', { buffer = args.buf, desc = 'Close man page' })

    -- <leader>mt: Table of contents
    vim.keymap.set(
      'n',
      '<leader>mt',
      '<cmd>lua require("man").show_toc()<CR>',
      { buffer = args.buf, desc = 'Man TOC' }
    )

    -- <leader>mn / <leader>mp: Next/prev section
    vim.keymap.set('n', '<leader>mn', function()
      local cur_name = vim.fn.expand '%:t':match '^(.-)%('
      local cur_sect = vim.b.man_sect or ''
      local idx = vim.fn.indexof(sections, cur_sect)
      local next_sect = sections[(idx + 1) % #sections + 1]
      vim.cmd('Man ' .. next_sect .. ' ' .. cur_name)
    end, { buffer = args.buf, desc = 'Next man section' })

    vim.keymap.set('n', '<leader>mp', function()
      local cur_name = vim.fn.expand '%:t':match '^(.-)%('
      local cur_sect = vim.b.man_sect or ''
      local idx = vim.fn.indexof(sections, cur_sect)
      local prev_sect = sections[(idx - 1) % #sections + 1]
      vim.cmd('Man ' .. prev_sect .. ' ' .. cur_name)
    end, { buffer = args.buf, desc = 'Prev man section' })
  end,
})

-- Custom man page finder (works on NixOS where man -k doesn't)
local manpage_items ---@type table[]|nil

local function man_finder()
  if manpage_items then return manpage_items end
  manpage_items = {}
  local ok, manpath = pcall(vim.fn.system, 'manpath 2>/dev/null')
  if not ok or manpath == '' then
    ok, manpath = pcall(vim.fn.system, 'man -w 2>/dev/null')
  end
  manpath = (ok and manpath or ''):gsub('%s+$', '')
  if manpath == '' then return manpage_items end
  for dir in manpath:gmatch '[^:]+' do
    local files = vim.fn.systemlist { 'fd', '--type', 'f', '--glob', '*.[0-9ln]*', dir }
    for _, f in ipairs(files) do
      local page, sect = f:match '.*/([^/]+)%.([0-9ln]+)[^.]*$'
      if page and sect then
        manpage_items[#manpage_items + 1] = {
          text = page .. '(' .. sect .. ')',
          page = page,
          section = sect,
          ref = page .. '(' .. sect .. ')',
        }
      end
    end
  end
  return manpage_items
end

-- Global: fuzzy-search man pages
vim.keymap.set('n', '<leader>fm', function()
  S.picker {
    source = {
      name = 'man',
      finder = man_finder,
      format = 'man',
      preview = function(ctx) vim.cmd('Man ' .. ctx.item.ref) end,
    },
  }
end, { desc = 'Search Man Pages' })
