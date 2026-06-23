-- force Escape key to always work
vim.keymap.set('i', '<Esc>', '<Esc>', { noremap = true, silent = true })
vim.keymap.set('i', 'jk', '<Esc>', { noremap = true, silent = true })

-- save and quit with leader keys
vim.keymap.set('n', '<leader>w', ':w<CR>', { noremap = true, silent = true, desc = 'Save file' })
vim.keymap.set('n', '<leader>q', ':wq<CR>', { noremap = true, silent = true, desc = 'Save and quit' })
vim.keymap.set('n', '<leader>qq', ':q!<CR>', { noremap = true, silent = true, desc = 'Quit without saving' })
vim.keymap.set('n', '<leader>t', ':tabnew | Telescope file_browser path=%:p:h select_buffer=true hidden=true<CR>', { desc = 'New tab with file explorer' })

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

-- runners
-- open current HTML file in browser
local function open_in_browser()
    local file = vim.fn.expand('%:p')
    local ext = vim.fn.expand('%:e')
    if ext ~= 'html' and ext ~= 'htm' then
        vim.notify('Not an HTML file', vim.log.levels.WARN)
        return
    end
    local opener
    if vim.fn.has('mac') == 1 then
        opener = 'open'
    elseif vim.fn.has('win32') == 1 or vim.fn.has('win64') == 1 then
        opener = 'start'
    else
        opener = 'xdg-open'
    end
    local ok = vim.fn.jobstart({ opener, file }, { detach = true })
    if ok == -1 or ok == 0 then
        vim.notify('Failed to open file in browser', vim.log.levels.ERROR)
    end
end

vim.keymap.set('n', '<leader>ob', open_in_browser, { desc = 'Open HTML in browser' })
vim.api.nvim_create_user_command('OpenInBrowser', open_in_browser, { desc = 'Open current HTML file in browser' })

-- run current Python file in a terminal split
local function run_python()
    if vim.fn.expand('%:e') ~= 'py' then
        vim.notify('Not a Python file', vim.log.levels.WARN)
        return
    end
    vim.cmd('split | terminal python3 ' .. vim.fn.shellescape(vim.fn.expand('%:p')))
end

vim.keymap.set('n', '<leader>rp', run_python, { desc = 'Run Python file' })
vim.api.nvim_create_user_command('RunPython', run_python, { desc = 'Run current Python file' })

-- run current Java file in a terminal split (compiles then runs)
local function run_java()
    if vim.fn.expand('%:e') ~= 'java' then
        vim.notify('Not a Java file', vim.log.levels.WARN)
        return
    end
    local file = vim.fn.shellescape(vim.fn.expand('%:p'))
    local dir  = vim.fn.shellescape(vim.fn.expand('%:p:h'))
    vim.cmd('split | terminal cd ' .. dir .. ' && javac ' .. file .. ' && java ' .. vim.fn.expand('%:t:r'))
end

vim.keymap.set('n', '<leader>rj', run_java, { desc = 'Run Java file' })
vim.api.nvim_create_user_command('RunJava', run_java, { desc = 'Run current Java file' })

