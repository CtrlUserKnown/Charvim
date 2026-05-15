vim.wo.number = true
vim.wo.relativenumber = true   

vim.opt.timeoutlen = 500

vim.opt.list = true
vim.opt.listchars = { tab = '▸ ', trail = '·', extends = '»', precedes = '«', nbsp = '␣', leadmultispace = '│   ', lead = '│'}

vim.opt.showcmd = true

vim.api.nvim_create_user_command('E', 'Telescope file_browser path=%:p:h select_buffer=true hidden=true', {})
vim.api.nvim_create_user_command('Tree', 'Telescope file_browser path=%:p:h select_buffer=true hidden=true', {})

vim.keymap.set('n', '<leader>e', ':Telescope file_browser path=%:p:h select_buffer=true hidden=true<CR>')
vim.keymap.set('n', '<leader>E', function()
    local root = vim.fs.root(0, { '.git', 'package.json', 'Makefile', 'pom.xml', 'build.gradle', 'Cargo.toml' })
    local path = root or vim.fn.getcwd()
    require('telescope').extensions.file_browser.file_browser({ path = path, hidden = true })
end)

vim.keymap.set('n', '<leader>g', ':Telescope live_grep<CR>', { noremap = true, silent = true, desc = 'Live grep' })

vim.scriptencoding = "utf-8"
vim.opt.encoding = "utf-8"
vim.opt.fileencoding = "utf-8"

vim.opt.backup = false

vim.opt.scrolloff = 10  -- was vim.scrolloff (global Lua var, had no effect)

vim.opt.expandtab = true
vim.opt.smarttab = true
vim.opt.smartindent = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.softtabstop = 4

vim.opt.swapfile = false

vim.opt.clipboard = "unnamedplus"

vim.opt.cursorline = true
vim.opt.cursorlineopt = 'number'

vim.opt.guicursor = "n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50"

vim.opt.cmdheight = 0
vim.opt.showcmd = false
