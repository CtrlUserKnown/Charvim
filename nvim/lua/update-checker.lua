local M = {}

local settings_path = vim.fn.stdpath('data') .. '/charvim_settings.json'
local pending_path  = vim.fn.stdpath('data') .. '/charvim_pending_update'

local function load_settings()
    local f = io.open(settings_path, 'r')
    if not f then return { enabled = true } end
    local raw = f:read('*a'); f:close()
    local ok, data = pcall(vim.fn.json_decode, raw)
    return (ok and type(data) == 'table') and data or { enabled = true }
end

local function save_settings(s)
    local f = io.open(settings_path, 'w')
    if not f then return end
    f:write(vim.fn.json_encode(s)); f:close()
end

local function read_pending()
    local f = io.open(pending_path, 'r')
    if not f then return nil end
    local v = vim.trim(f:read('*a')); f:close()
    return v ~= '' and v or nil
end

local function write_pending(version)
    local f = io.open(pending_path, 'w')
    if not f then return end
    f:write(version); f:close()
end

local function clear_pending()
    os.remove(pending_path)
end

function M.get_version()
    local config = vim.fn.resolve(vim.fn.stdpath('config'))
    local dir = config
    for _ = 1, 5 do
        local f = io.open(dir .. '/CHANGELOG', 'r')
        if f then
            for line in f:lines() do
                local ver = line:match('^## %[(%d+%.%d+%.%d+)%]')
                if ver then f:close(); return ver end
            end
            f:close()
        end
        dir = vim.fn.fnamemodify(dir, ':h')
    end
    return nil
end

local function compare_versions(a, b)
    local function parts(v)
        local x, y, z = v:match('^(%d+)%.(%d+)%.(%d+)$')
        return tonumber(x) or 0, tonumber(y) or 0, tonumber(z) or 0
    end
    local a1, a2, a3 = parts(a)
    local b1, b2, b3 = parts(b)
    if b1 ~= a1 then return b1 > a1 end
    if b2 ~= a2 then return b2 > a2 end
    return b3 > a3
end

local function find_repo_root()
    local config = vim.fn.resolve(vim.fn.stdpath('config'))
    local dir = config
    for _ = 1, 5 do
        if vim.fn.isdirectory(dir .. '/.git') == 1 then return dir end
        dir = vim.fn.fnamemodify(dir, ':h')
    end
    return nil
end

local function show_popup(current, latest)
    local ok, pickers = pcall(require, 'telescope.pickers')
    if not ok then
        vim.notify(
            string.format('CharVim v%s available (current: v%s)\nRun: git pull in the CharVim repo', latest, current),
            vim.log.levels.INFO
        )
        return
    end

    local finders      = require('telescope.finders')
    local conf         = require('telescope.config').values
    local actions      = require('telescope.actions')
    local action_state = require('telescope.actions.state')

    local entries = {
        { icon = '  ', label = 'Update now',             id = 'update'  },
        { icon = '   ', label = 'Remind me later',       id = 'later'   },
        { icon = '  ', label = 'Skip v' .. latest,      id = 'skip'    },
        { icon = '  ', label = 'Disable update checks', id = 'disable' },
    }

    pickers.new({
        layout_strategy  = 'center',
        layout_config    = { width = 0.38, height = 0.38 },
        sorting_strategy = 'ascending',
    }, {
        prompt_title = string.format('  CharVim v%s available  (you have v%s)', latest, current),
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

                local id       = entry.value.id
                local settings = load_settings()

                if id == 'update' then
                    local root = find_repo_root()
                    if not root then
                        vim.notify('Could not find CharVim repo root.', vim.log.levels.ERROR)
                        return
                    end
                    vim.notify('Updating CharVim…', vim.log.levels.INFO)
                    vim.fn.jobstart({ 'git', '-C', root, 'pull' }, {
                        on_exit = function(_, code)
                            vim.schedule(function()
                                clear_pending()
                                if code == 0 then
                                    vim.notify(
                                        'Updated to v' .. latest .. '. Restart Neovim to apply.',
                                        vim.log.levels.INFO
                                    )
                                else
                                    vim.notify(
                                        'Update failed. Try: git -C ' .. root .. ' pull',
                                        vim.log.levels.ERROR
                                    )
                                end
                            end)
                        end,
                    })

                elseif id == 'later' then
                    -- leave pending file; will prompt again next startup

                elseif id == 'skip' then
                    settings.skipped = latest
                    save_settings(settings)
                    clear_pending()

                elseif id == 'disable' then
                    settings.enabled = false
                    save_settings(settings)
                    clear_pending()
                    vim.notify(
                        'Update checks disabled. Re-enable with :CharvimUpdateEnable',
                        vim.log.levels.INFO
                    )
                end
            end)
            return true
        end,
    }):find()
end

local function fetch_latest(current, settings)
    vim.fn.jobstart({
        'curl', '-sf', '--max-time', '5',
        '-H', 'Accept: application/vnd.github.v3+json',
        'https://api.github.com/repos/CrtlUserKnown/Charvim/releases/latest',
    }, {
        stdout_buffered = true,
        on_stdout = function(_, data)
            local raw = table.concat(data or {}, '')
            if raw == '' then return end
            local ok, decoded = pcall(vim.fn.json_decode, raw)
            if not ok or type(decoded) ~= 'table' or not decoded.tag_name then return end
            local latest = decoded.tag_name:match('^v?(%d+%.%d+%.%d+)$')
            if not latest then return end
            if settings.skipped == latest then return end
            if not compare_versions(current, latest) then return end

            write_pending(latest)
            vim.schedule(function()
                show_popup(current, latest)
            end)
        end,
    })
end

function M.setup()
    vim.api.nvim_create_user_command('CharvimUpdateCheck', function()
        local s = load_settings()
        s.enabled = true
        save_settings(s)
        local cur = M.get_version()
        if cur then fetch_latest(cur, s) end
    end, { desc = 'Check for CharVim updates now' })

    vim.api.nvim_create_user_command('CharvimUpdateEnable', function()
        local s = load_settings()
        s.enabled = true
        s.skipped = nil
        save_settings(s)
        vim.notify('Update checks enabled.', vim.log.levels.INFO)
    end, { desc = 'Enable CharVim update checks' })

    vim.api.nvim_create_user_command('CharvimUpdateDisable', function()
        local s = load_settings()
        s.enabled = false
        save_settings(s)
        clear_pending()
        vim.notify(
            'Update checks disabled. Re-enable with :CharvimUpdateEnable',
            vim.log.levels.INFO
        )
    end, { desc = 'Disable CharVim update checks' })

    local settings = load_settings()
    if not settings.enabled then return end

    local current = M.get_version()
    if not current then return end

    -- If a previous session already detected an update, surface it 1 s after
    -- startup so the dashboard has time to render first.
    local pending = read_pending()
    if pending and settings.skipped ~= pending and compare_versions(current, pending) then
        vim.defer_fn(function()
            show_popup(current, pending)
        end, 1000)
        return
    end

    -- Otherwise kick off a background fetch (async, does not block startup)
    fetch_latest(current, settings)
end

M.setup()
return M
