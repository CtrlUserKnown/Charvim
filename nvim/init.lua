vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

local env_file = vim.fn.stdpath("config") .. "/../.env"
if vim.fn.filereadable(env_file) == 1 then
    for line in io.lines(env_file) do
        local key, value = line:match("^([%w_]+)=(.*)$")
        if key and value ~= "" then
            vim.fn.setenv(key, value)
        end
    end
end

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
require('rename-config')

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

