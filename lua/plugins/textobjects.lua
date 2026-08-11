-- Treesitter-based text objects: select, move, and swap using syntax-aware captures.
-- Uses the modern (main branch) API: keymaps are defined explicitly here.

local ntt_select = require 'nvim-treesitter-textobjects.select'
local ntt_move = require 'nvim-treesitter-textobjects.move'
local ntt_swap = require 'nvim-treesitter-textobjects.swap'

require('nvim-treesitter-textobjects').setup {
  select = {
    lookahead = true,
    selection_modes = {
      ['@function.outer'] = 'V',
      ['@class.outer'] = 'V',
    },
    include_surrounding_whitespace = true,
  },
  move = {
    set_jumps = true,
  },
}

local function select(query)
  return function() ntt_select.select_textobject(query) end
end

local function move_to(query, fn)
  return function() ntt_move[fn](query) end
end

-- Select: inner / around
for _, mode in ipairs { 'x', 'o' } do
  vim.keymap.set(mode, 'if', select '@function.inner', { desc = 'Select Inner Function' })
  vim.keymap.set(mode, 'af', select '@function.outer', { desc = 'Select Around Function' })
  vim.keymap.set(mode, 'ic', select '@class.inner', { desc = 'Select Inner Class' })
  vim.keymap.set(mode, 'ac', select '@class.outer', { desc = 'Select Around Class' })
  vim.keymap.set(mode, 'ia', select '@parameter.inner', { desc = 'Select Inner Argument' })
  vim.keymap.set(mode, 'aa', select '@parameter.outer', { desc = 'Select Around Argument' })
  vim.keymap.set(mode, 'il', select '@loop.inner', { desc = 'Select Inner Loop' })
  vim.keymap.set(mode, 'al', select '@loop.outer', { desc = 'Select Around Loop' })
  vim.keymap.set(mode, 'id', select '@conditional.inner', { desc = 'Select Inner Conditional' })
  vim.keymap.set(mode, 'ad', select '@conditional.outer', { desc = 'Select Around Conditional' })
end

-- Move: jump between functions, classes, arguments, conditionals
for _, mode in ipairs { 'n', 'x', 'o' } do
  vim.keymap.set(
    mode,
    ']m',
    move_to('@function.outer', 'goto_next_start'),
    { desc = 'Next Function Start' }
  )
  vim.keymap.set(
    mode,
    '[m',
    move_to('@function.outer', 'goto_previous_start'),
    { desc = 'Prev Function Start' }
  )
  vim.keymap.set(
    mode,
    ']M',
    move_to('@function.outer', 'goto_next_end'),
    { desc = 'Next Function End' }
  )
  vim.keymap.set(
    mode,
    '[M',
    move_to('@function.outer', 'goto_previous_end'),
    { desc = 'Prev Function End' }
  )
  vim.keymap.set(
    mode,
    ']c',
    move_to('@class.outer', 'goto_next_start'),
    { desc = 'Next Class Start' }
  )
  vim.keymap.set(
    mode,
    '[c',
    move_to('@class.outer', 'goto_previous_start'),
    { desc = 'Prev Class Start' }
  )
  vim.keymap.set(
    mode,
    ']a',
    move_to('@parameter.outer', 'goto_next_start'),
    { desc = 'Next Argument' }
  )
  vim.keymap.set(
    mode,
    '[a',
    move_to('@parameter.outer', 'goto_previous_start'),
    { desc = 'Prev Argument' }
  )
  vim.keymap.set(
    mode,
    ']d',
    move_to('@conditional.outer', 'goto_next'),
    { desc = 'Next Conditional' }
  )
  vim.keymap.set(
    mode,
    '[d',
    move_to('@conditional.outer', 'goto_previous'),
    { desc = 'Prev Conditional' }
  )
end

-- Swap: reorder function parameters / arguments
vim.keymap.set(
  'n',
  ']x',
  function() ntt_swap.swap_next '@parameter.inner' end,
  { desc = 'Swap Arg Next' }
)
vim.keymap.set(
  'n',
  '[x',
  function() ntt_swap.swap_previous '@parameter.inner' end,
  { desc = 'Swap Arg Prev' }
)
