local M = {}

local function find_repo_root()
    local config = vim.fn.resolve(vim.fn.stdpath('config'))
    local dir = config
    for _ = 1, 5 do
        if vim.fn.isdirectory(dir .. '/.git') == 1 then return dir end
        dir = vim.fn.fnamemodify(dir, ':h')
    end
    return nil
end

local function nvim_config_path()
    return vim.fn.expand('~/.config/nvim')
end

local function confirm_then(prompt, fn)
    vim.ui.input({ prompt = prompt .. '  (type YES to confirm): ' }, function(input)
        if input == 'YES' then
            fn()
        else
            vim.notify('Cancelled.', vim.log.levels.INFO)
        end
    end)
end

local function remove_charvim_data()
    local data = vim.fn.stdpath('data')
    for _, name in ipairs({ 'charvim_settings.json', 'charvim_pending_update', 'charvim_theme' }) do
        os.remove(data .. '/' .. name)
    end
end

local function do_reinstall()
    local root = find_repo_root()
    if not root then
        vim.notify('Cannot find CharVim repo root.', vim.log.levels.ERROR)
        return
    end
    local setup = root .. '/setup.sh'
    if vim.fn.filereadable(setup) == 1 then
        vim.cmd('split | terminal bash ' .. vim.fn.fnameescape(setup))
    else
        -- Fallback: recreate symlink
        local cfg = nvim_config_path()
        local nvim_dir = root .. '/nvim'
        if vim.fn.isdirectory(nvim_dir) == 1 then
            vim.fn.system({ 'rm', '-rf', cfg })
            vim.fn.system({ 'ln', '-s', nvim_dir, cfg })
            vim.notify('Symlink restored at ' .. cfg .. '. Restart Neovim.', vim.log.levels.INFO)
        else
            vim.notify('Cannot find nvim/ directory in repo.', vim.log.levels.ERROR)
        end
    end
end

local function do_normal_uninstall()
    confirm_then('Remove CharVim config (keeps repo and plugins)', function()
        local cfg = nvim_config_path()
        vim.fn.system({ 'rm', '-rf', cfg })
        remove_charvim_data()
        vim.notify(
            'Normal uninstall complete. Config removed; repo and plugins untouched.\nQuit Neovim to finish.',
            vim.log.levels.WARN
        )
    end)
end

local function do_complete_uninstall()
    confirm_then('COMPLETE uninstall — removes config, plugins, Mason, and repo', function()
        local cfg  = nvim_config_path()
        local data = vim.fn.stdpath('data')
        local root = find_repo_root()

        vim.fn.system({ 'rm', '-rf', cfg })
        vim.fn.system({ 'rm', '-rf', data .. '/lazy' })
        vim.fn.system({ 'rm', '-rf', data .. '/mason' })
        vim.fn.system({ 'rm', '-rf', data .. '/undodir' })
        remove_charvim_data()

        -- Only delete repo if it looks like a charvim directory (safety guard)
        if root then
            local name = vim.fn.fnamemodify(root, ':t'):lower()
            if name:match('charvim') or name:match('charvim') then
                vim.fn.system({ 'rm', '-rf', root })
            else
                vim.notify('Repo at ' .. root .. ' not removed (name does not contain "charvim"). Remove manually.', vim.log.levels.WARN)
            end
        end

        vim.notify(
            'Complete uninstall done. Quit Neovim — the process will error after this since the config is gone.',
            vim.log.levels.WARN
        )
    end)
end

function M.open()
    local ok, pickers = pcall(require, 'telescope.pickers')
    if not ok then
        vim.notify('Use :CharvimUninstall', vim.log.levels.ERROR)
        return
    end

    local finders      = require('telescope.finders')
    local conf         = require('telescope.config').values
    local actions      = require('telescope.actions')
    local action_state = require('telescope.actions.state')

    local entries = {
        { icon = '  ', label = 'Reinstall  (repair / re-run setup)',      id = 'reinstall' },
        { icon = '  ', label = 'Normal uninstall  (remove config only)',   id = 'normal'    },
        { icon = '  ', label = 'Complete uninstall  (remove everything)',  id = 'complete'  },
        { icon = '  ', label = 'Cancel',                                   id = 'cancel'    },
    }

    pickers.new({
        layout_strategy  = 'center',
        layout_config    = { width = 0.48, height = 0.38 },
        sorting_strategy = 'ascending',
    }, {
        prompt_title = '  CharVim — Uninstall / Reinstall',
        previewer    = false,
        finder = finders.new_table({
            results = entries,
            entry_maker = function(e)
                return { value = e, display = e.icon .. e.label, ordinal = e.label }
            end,
        }),
        sorter = conf.generic_sorter({}),
        attach_mappings = function(prompt_bufnr)
            actions.select_default:replace(function()
                local entry = action_state.get_selected_entry()
                actions.close(prompt_bufnr)
                if not entry then return end
                vim.schedule(function()
                    local id = entry.value.id
                    if id == 'reinstall' then
                        do_reinstall()
                    elseif id == 'normal' then
                        do_normal_uninstall()
                    elseif id == 'complete' then
                        do_complete_uninstall()
                    end
                end)
            end)
            return true
        end,
    }):find()
end

function M.setup()
    vim.api.nvim_create_user_command('CharvimUninstall', M.open, {
        desc = 'Open CharVim uninstall / reinstall menu',
    })
end

M.setup()
return M
