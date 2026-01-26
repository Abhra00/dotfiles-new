-- Keymaps
-- Some QoL neovim keymaps

-- For convenience
local keymap = vim.keymap
local opts = { noremap = true, silent = true }

-- Clear highlights
vim.keymap.set('n', '<Esc>', '<Cmd>noh<CR>', opts)

-- Keep last yanked when pasting
keymap.set('v', 'p', '"_dP', opts)

-- Delete a word backwards
keymap.set('n', 'dw', 'vb"_d')

-- Select all
keymap.set('n', '<C-S-a>', 'gg<S-v>G')

-- Disable continuations
keymap.set('n', '<Leader>o', 'o<Esc>^Da', opts)
keymap.set('n', '<Leader>O', 'O<Esc>^Da', opts)

-- Jumplist
keymap.set('n', '<C-m>', '<C-i>', opts)
keymap.set('n', '<C-,>', '<C-o>', opts)

-- Tab management
keymap.set('n', 'te', ':tabedit')
keymap.set('n', 'tx', '<Cmd>tabclose<CR>', opts)
keymap.set('n', '<Tab>', '<Cmd>tabnext<CR>', opts)
keymap.set('n', '<S-Tab>', '<Cmd>tabprev<CR>', opts)

-- Split window
keymap.set('n', 'ss', '<Cmd>split<CR>', opts)
keymap.set('n', 'sv', '<Cmd>vsplit<CR>', opts)

-- Move window
keymap.set('n', 'sh', '<C-w>h')
keymap.set('n', 'sj', '<C-w>j')
keymap.set('n', 'sk', '<C-w>k')
keymap.set('n', 'sl', '<C-w>l')

-- Resize window
keymap.set('n', '<C-w><Left>', '<C-w><')
keymap.set('n', '<C-w><Right>', '<C-w>>')
keymap.set('n', '<C-w><Up>', '<C-w>+')
keymap.set('n', '<C-w><Down>', '<C-w>-')

-- Diagnostics
keymap.set('n', '<C-j>', function()
  vim.diagnostic.jump { count = 1, float = true }
end, opts)

keymap.set('n', '<C-k>', function()
  vim.diagnostic.jump { count = -1, float = true }
end, opts)

-- Lazygit
keymap.set('n', '<leader>gl', function()
  require('utils.float_term').float_term('lazygit', {
    size = { width = 0.85, height = 0.8 },
    cwd = vim.b.gitsigns_status_dict.root,
  })
end, { desc = 'Lazygit' })

-- Hex to hsl
keymap.set('n', '<leader>r', function()
  require('utils.hsl').replaceHexWithHSL()
end)
