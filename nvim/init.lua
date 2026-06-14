vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.api.nvim_set_hl(0, 'CursorLineNr', {
    fg = '#f6c177',
    bold = true
})

require('statusline')
require('options')
require('keymaps')
require('theme-switcher')
require('multicursor').setup()

require('autoclose').setup()

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable",
        lazypath })
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup('plugins', {
    change_detection = { enabled = true, notify = false },
    timeout = 120000,
    git = {
        clone_params = { depth = 1 },
    },
})

require('lsp-config')
require('treesitter-config')
require('completion-config')

vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })

vim.api.nvim_create_autocmd("FileType", {
    pattern = "crystal",
    callback = function()
        if vim.bo.syntax == 'on' or vim.bo.syntax == 'crystal' then
            vim.cmd("set syntax=ruby")
        end
    end
})

local dap_ok, _ = pcall(require, 'dap')
if dap_ok then
    require('dap-config')
end
