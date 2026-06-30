local alpha     = require('alpha')
local dashboard = require('alpha.themes.dashboard')

-- Read ASCII art from file
local function read_ascii_art()
    local art_path = vim.fn.stdpath('config') .. '/lua/img/charVim.txt'
    local file = io.open(art_path, 'r')
    if file then
        local lines = {}
        for line in file:lines() do
            if line:sub(1, 1) == '[' and line:sub(-1, -1) == ']' then
                table.insert(lines, line:sub(2, -2))
            else
                table.insert(lines, line)
            end
        end
        file:close()
        return lines
    end
    return {
        "                                 ",
        " \xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88        \xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88  ",
        "   \xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88             \xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88    ",
        "   \xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88            \xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88      ",
        "   \xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88            \xe2\x96\x88\xe2\x96\x88\xe2\x96\x88        ",
        "   \xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88          \xe2\x96\x88\xe2\x96\x88\xe2\x96\x88          ",
        "   \xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88        \xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88           ",
        "   \xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88       \xe2\x96\x88\xe2\x96\x88\xe2\x96\x88             ",
        "   \xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88     \xe2\x96\x88\xe2\x96\x88\xe2\x96\x88               ",
        "   \xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88   \xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88                ",
        "   \xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88  \xe2\x96\x88\xe2\x96\x88\xe2\x96\x88         \xe2\x96\x88\xe2\x96\x88       ",
        "   \xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88        \xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88      ",
        "   \xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88       \xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88      ",
        "   \xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88        \xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88      ",
        "  \xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88         \xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88      ",
        "  \xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88           \xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88       ",
        "  \xe2\x96\x88\xe2\x96\x88\xe2\x96\x88              \xe2\x96\x88\xe2\x96\x88\xe2\x96\x88\xe2\x96\x88          ",
        "                                 ",
    }
end

-- ─── Button grid ────────────────────────────────────────────────────────────
-- Each entry: { key, icon+label, action }
local grid_items = {
    { 'f', '   Find file',    ':Telescope find_files<CR>'                                     },
    { 'r', '   Recent',       ':Telescope oldfiles<CR>'                                        },
    { 'p', '   Projects',     ':Telescope projects<CR>'                                        },
    { 'n', '   New file',     ':ene <BAR> startinsert<CR>'                                     },
    { 'g', '   Find text',    ':Telescope live_grep<CR>'                                       },
    { 'c', '   Config',       ':e $MYVIMRC<CR>'                                                },
    { 'l', '󰒲  Lazy',         ':Lazy<CR>'                                                      },
    { 'm', '   Mason',        ':Mason<CR>'                                                     },
    { 't', '   Themes',       ':ThemeSelect<CR>'                                               },
    { 'd', '   Docs',         nil  },  -- handled specially (open browser)
    { 'u', '  Manage',       ':CharvimUninstall<CR>'                                          },
    { 'q', '   Quit',         ':qa<CR>'                                                        },
}

local DOCS_URL = 'https://github.com/CtrlUserKnown/Charvim/wiki'

local function open_docs()
    local opener = vim.fn.has('mac') == 1 and 'open' or 'xdg-open'
    local ok = vim.fn.jobstart({ opener, DOCS_URL }, { detach = true })
    if ok <= 0 then
        vim.notify('Could not open browser. Visit: ' .. DOCS_URL, vim.log.levels.INFO)
    end
end

-- Pad a string to display-width `w` (handles multibyte / wide chars)
local function pad_to(s, w)
    local dw = vim.fn.strdisplaywidth(s)
    return dw < w and (s .. string.rep(' ', w - dw)) or s
end

local COL_W = 30  -- display-width of each column cell

local function build_grid()
    local lines = {}
    for i = 1, #grid_items, 2 do
        local a = grid_items[i]
        local b = grid_items[i + 1]
        local left  = pad_to(string.format('  [%s]  %s', a[1], a[2]), COL_W)
        local right = b and string.format('  [%s]  %s', b[1], b[2]) or ''
        table.insert(lines, left .. right)
    end
    return lines
end

local grid_section = {
    type = 'text',
    val  = build_grid(),
    opts = { position = 'center', hl = 'String' },
}

-- Register keymaps when alpha buffer is active
vim.api.nvim_create_autocmd('User', {
    pattern  = 'AlphaReady',
    callback = function()
        local buf = vim.api.nvim_get_current_buf()
        for _, item in ipairs(grid_items) do
            local key    = item[1]
            local action = item[3]
            if key == 'd' then
                vim.keymap.set('n', key, open_docs, { buffer = buf, silent = true, nowait = true })
            elseif action then
                vim.keymap.set('n', key, action, { buffer = buf, silent = true, nowait = true })
            end
        end
    end,
})

-- ─── Footer ─────────────────────────────────────────────────────────────────
local function get_charvim_version()
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

local function footer()
    local datetime  = os.date(' %d-%m-%Y   %H:%M:%S')
    local v         = vim.version()
    local nvim_ver  = '   v' .. v.major .. '.' .. v.minor .. '.' .. v.patch
    local cv        = get_charvim_version()
    local cv_str    = cv and ('    charvim v' .. cv) or ''
    return datetime .. '   ' .. nvim_ver .. cv_str
end

-- ─── Layout ──────────────────────────────────────────────────────────────────
dashboard.section.header.val = read_ascii_art()

local footer_section = {
    type = 'text',
    val  = footer(),
    opts = { position = 'center', hl = 'Comment' },
}

alpha.setup({
    layout = {
        { type = 'padding', val = 2 },
        dashboard.section.header,
        { type = 'padding', val = 2 },
        grid_section,
        { type = 'padding', val = 1 },
        footer_section,
    },
    opts = { noautocmd = true },
})

vim.keymap.set('n', '<leader>d', ':Alpha<CR>', { desc = 'Dashboard' })
vim.keymap.set('n', '<leader>p', ':Telescope projects<CR>', { desc = 'Projects' })
