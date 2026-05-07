local mode_map = {
    n       = { label = 'N', hl = 'StatusLineNormal' },
    i       = { label = 'I', hl = 'StatusLineInsert' },
    v       = { label = 'V', hl = 'StatusLineVisual' },
    V       = { label = 'V', hl = 'StatusLineVisual' },
    ['\22'] = { label = 'V', hl = 'StatusLineVisual' },
    c       = { label = 'C', hl = 'StatusLineCommand' },
    R       = { label = 'R', hl = 'StatusLineReplace' },
    r       = { label = 'R', hl = 'StatusLineReplace' },
    t       = { label = 'T', hl = 'StatusLineNormal' },
}

local name_map = {
    n       = 'NORMAL',
    i       = 'INSERT',
    v       = 'VISUAL',
    V       = 'V-LINE',
    ['\22'] = 'V-BLOCK',
    c       = 'COMMAND',
    s       = 'SELECT',
    S       = 'S-LINE',
    ['\19'] = 'S-BLOCK',
    R       = 'REPLACE',
    r       = 'REPLACE',
    ['!']   = 'SHELL',
    t       = 'TERMINAL',
}

local function get_mode_info()
    local mode = vim.api.nvim_get_mode().mode
    local info = mode_map[mode] or { label = mode:upper(), hl = 'StatusLineNormal' }
    return info.label, info.hl, (name_map[mode] or mode:upper())
end

function _G.custom_statusline()
    local label, hl, name = get_mode_info()

    local filename = vim.fn.expand('%:t')
    if filename == '' then filename = '[No Name]' end

    local modified = vim.bo.modified and ' [+]' or ''

    local saved_status = ''
    if vim.g.statusline_save_msg then
        saved_status = string.format('%%#StatusLineSaved# %s %%*', vim.g.statusline_save_msg)
        vim.defer_fn(function()
            vim.g.statusline_save_msg = nil
            vim.cmd('redrawstatus')
        end, 2000)
    end

    local left = string.format('%%#%s# %s %%* %s%s', hl, label, filename, modified)
    local right = string.format('%s %s %%p%%%% %%c Help', saved_status, name)

    return left .. '%=' .. right
end

-- mode highlights
vim.api.nvim_set_hl(0, 'StatusLineNormal',  { fg = '#191724', bg = '#f6c177', bold = true })
vim.api.nvim_set_hl(0, 'StatusLineInsert',  { fg = '#191724', bg = '#9ccfd8', bold = true })
vim.api.nvim_set_hl(0, 'StatusLineVisual',  { fg = '#191724', bg = '#c4a7e7', bold = true })
vim.api.nvim_set_hl(0, 'StatusLineCommand', { fg = '#191724', bg = '#eb6f92', bold = true })
vim.api.nvim_set_hl(0, 'StatusLineReplace', { fg = '#191724', bg = '#eb6f92', bold = true })
vim.api.nvim_set_hl(0, 'StatusLineSaved',   { fg = '#191724', bg = '#c4a7e7', bold = true })
vim.api.nvim_set_hl(0, 'StatusLine',        { fg = '#e0def4', bg = '#191724' })
vim.api.nvim_set_hl(0, 'StatusLineNC',      { fg = '#6e6a86', bg = '#191724' })

vim.opt.statusline = '%!v:lua.custom_statusline()'
vim.opt.laststatus = 2

vim.api.nvim_create_autocmd('BufWritePost', {
    callback = function()
        vim.g.statusline_save_msg = 'written'
        vim.cmd('redrawstatus')
    end
})

vim.api.nvim_create_autocmd('ModeChanged', {
    callback = function()
        vim.cmd('redrawstatus')
    end
})
