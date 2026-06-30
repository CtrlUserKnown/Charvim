local M = {}

local function is_unnamed()
    return vim.fn.expand('%') == ''
end

local function has_lsp_format()
    for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
        if client:supports_method('textDocument/formatting') then
            return true
        end
    end
    return false
end

local function do_save()
    if is_unnamed() then
        vim.notify('No file name — use Save As', vim.log.levels.WARN)
        return
    end
    local ok, err = pcall(vim.cmd, 'write')
    if not ok then
        vim.notify('Save failed: ' .. tostring(err), vim.log.levels.ERROR)
    end
end

local function do_save_as()
    local default = vim.fn.expand('%:p')
    if default == '' then default = vim.fn.getcwd() .. '/' end
    vim.ui.input({ prompt = 'Save as: ', default = default }, function(name)
        if not name or name == '' then return end
        local ok, err = pcall(vim.cmd, 'saveas ' .. vim.fn.fnameescape(name))
        if not ok then
            vim.notify('Save As failed: ' .. tostring(err), vim.log.levels.ERROR)
        end
    end)
end

local function do_format_save()
    local ok, err = pcall(vim.lsp.buf.format, { async = false, timeout_ms = 3000 })
    if not ok then
        vim.notify('Format failed: ' .. tostring(err) .. '\nSaving without format…', vim.log.levels.WARN)
    end
    do_save()
end

local function do_save_all()
    local ok, err = pcall(vim.cmd, 'wall')
    if not ok then
        vim.notify('Save All failed: ' .. tostring(err), vim.log.levels.ERROR)
    end
end

function M.open()
    local ok, pickers = pcall(require, 'telescope.pickers')
    if not ok then
        do_save()
        return
    end

    local finders      = require('telescope.finders')
    local conf         = require('telescope.config').values
    local actions      = require('telescope.actions')
    local action_state = require('telescope.actions.state')

    local unnamed = is_unnamed()
    local fmt     = not unnamed and has_lsp_format()

    local entries
    if unnamed then
        entries = {
            { icon = '  ', label = 'Save As…',      fn = do_save_as  },
        }
    else
        entries = {
            { icon = '  ', label = 'Save',           fn = do_save     },
            { icon = '  ', label = 'Save As…',      fn = do_save_as  },
        }
        if fmt then
            table.insert(entries, { icon = '  ', label = 'Format & Save', fn = do_format_save })
        end
        table.insert(entries, { icon = '  ', label = 'Save All',      fn = do_save_all })
    end

    pickers.new({
        layout_strategy  = 'center',
        layout_config    = { width = 0.28, height = 0.35 },
        sorting_strategy = 'ascending',
    }, {
        prompt_title = '  Save',
        previewer    = false,
        finder = finders.new_table({
            results = entries,
            entry_maker = function(e)
                return {
                    value   = e,
                    display = e.icon .. e.label,
                    ordinal = e.label,
                }
            end,
        }),
        sorter = conf.generic_sorter({}),
        attach_mappings = function(prompt_bufnr)
            actions.select_default:replace(function()
                local entry = action_state.get_selected_entry()
                actions.close(prompt_bufnr)
                if entry then
                    vim.schedule(function()
                        entry.value.fn()
                    end)
                end
            end)
            return true
        end,
    }):find()
end

function M.setup()
    vim.keymap.set('n', '<leader>W', M.open, { desc = 'Save file (popup)' })
end

M.setup()
return M
