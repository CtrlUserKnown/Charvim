-- force Escape key to always work
vim.keymap.set('i', '<Esc>', '<Esc>', { noremap = true, silent = true })
vim.keymap.set('i', 'jk', '<Esc>', { noremap = true, silent = true })

-- save and quit with leader keys
vim.keymap.set('n', '<leader>w', ':w<CR>', { noremap = true, silent = true, desc = 'Save file' })
vim.keymap.set('n', '<leader>q', ':wq<CR>', { noremap = true, silent = true, desc = 'Save and quit' })
vim.keymap.set('n', '<leader>qq', ':q!<CR>', { noremap = true, silent = true, desc = 'Quit without saving' })

-- go to beginning and end of file
vim.keymap.set('n', '[[', 'gg', { noremap = true, silent = true, desc = 'Go to beginning of file' })
vim.keymap.set('n', ']]', 'G', { noremap = true, silent = true, desc = 'Go to end of file' })

-- go to beginning and end of line
vim.keymap.set('n', 'H', '0', { noremap = true, silent = true, desc = 'Go to beginning of line' })
vim.keymap.set('n', 'L', '$', { noremap = true, silent = true, desc = 'Go to end of line' })
vim.keymap.set('v', 'H', '0', { noremap = true, silent = true, desc = 'Go to beginning of line' })
vim.keymap.set('v', 'L', '$', { noremap = true, silent = true, desc = 'Go to end of line' })

-- paragraph navigation with Option + [ and ]
vim.keymap.set('n', '<M-[>', '{', { noremap = true, silent = true, desc = 'Previous paragraph' })
vim.keymap.set('n', '<M-]>', '}', { noremap = true, silent = true, desc = 'Next paragraph' })
vim.keymap.set('v', '<M-[>', '{', { noremap = true, silent = true, desc = 'Previous paragraph' })
vim.keymap.set('v', '<M-]>', '}', { noremap = true, silent = true, desc = 'Next paragraph' })

-- Move line up and down with option/alt + j/k
vim.keymap.set('n', '<A-k>', ':m .-2<CR>==', { desc = 'Move line up' })
vim.keymap.set('n', '<A-j>', ':m .+1<CR>==', { desc = 'Move line down' })
vim.keymap.set('v', '<A-k>', ":m '<-2<CR>gv=gv", { desc = 'Move selection up' })
vim.keymap.set('v', '<A-j>', ":m '>+1<CR>gv=gv", { desc = 'Move selection down' })
vim.keymap.set('i', '<C-k>', '<Esc>:m .-2<CR>==gi', { desc = 'Move line up' })
vim.keymap.set('i', '<C-j>', '<Esc>:m .+1<CR>==gi', { desc = 'Move line down' })

-- Copy line up and down with ctrl + shift + j/k
vim.keymap.set('n', '<C-S-k>', ':t .-1<CR>==', { desc = 'Copy line up' })
vim.keymap.set('n', '<C-S-j>', ':t .<CR>==', { desc = 'Copy line down' })
vim.keymap.set('v', '<C-S-k>', ":t '<-1<CR>gv=gv", { desc = 'Copy selection up' })
vim.keymap.set('v', '<C-S-j>', ":t '><CR>gv=gv", { desc = 'Copy selection down' })

-- split navigation handled by vim-tmux-navigator
vim.g.tmux_navigator_no_mappings = 1

-- terminal shortcut to run command without having to press :!
vim.keymap.set('n', ';', ':!', { noremap = true })
