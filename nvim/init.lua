-- CharVim — Neovim Configuration
-- Author: CrtlUserKnown
-- Version: 1.5.4

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

-- Support user-plugins.lua (git-ignored) for personal plugin additions
local lazy_specs = { { import = 'plugins' } }
if vim.fn.filereadable(vim.fn.stdpath('config') .. '/lua/user-plugins.lua') == 1 then
    lazy_specs[#lazy_specs + 1] = { import = 'user-plugins' }
end

require('lazy').setup(lazy_specs, {
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
require('save-popup')
require('update-checker')
require('uninstall')

-- Auto-create user customization templates on first run (git-ignored, safe across updates)
local function ensure_user_template(path, content)
    if vim.fn.filereadable(path) == 0 then
        local f = io.open(path, 'w')
        if f then f:write(content); f:close() end
    end
end
local lua_dir = vim.fn.stdpath('config') .. '/lua/'
ensure_user_template(lua_dir .. 'user.lua', [[
-- user.lua — personal customizations (git-ignored, never overwritten by updates)
-- Add keymaps, options, autocommands, or anything else here.
-- This file is loaded last, so it can override any default setting.
--
-- vim.opt.wrap = true
-- vim.keymap.set('n', '<leader>x', ':!echo hi<CR>', { desc = 'My command' })
]])
ensure_user_template(lua_dir .. 'user-plugins.lua', [[
-- user-plugins.lua — personal plugins (git-ignored, never overwritten by updates)
-- Return a list of lazy.nvim plugin specs: https://lazy.folke.io/spec
return {}
]])

-- Load user customization last so it can override anything
pcall(require, 'user')

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

