local status_ok, ts = pcall(require, 'nvim-treesitter')
if not status_ok then return end

vim.filetype.add({
    extension = { cr = 'crystal', plist = 'xml' },
})

ts.setup({
    ensure_installed = {
        "c", "lua", "vim", "vimdoc", "query",
        "javascript", "typescript", "python", "rust", "go",
        "html", "css", "json", "markdown", "bash", "yaml", "toml",
        "xml"
    },

    sync_install = false,
    auto_install = true,
    ignore_install = {},

    highlight = {
        enable = true,
        disable = function(lang, buf)
            local max_filesize = 100 * 1024
            -- get_parser() returns nil on failure in 0.12 instead of throwing
            local parser = vim.treesitter.get_parser(buf, lang)
            if not parser then return true end
            local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
            if ok and stats and stats.size > max_filesize then return true end
        end,
        additional_vim_regex_highlighting = false,
    },

    indent = {
        enable = true,
        disable = { "python" },
    },

    incremental_selection = {
        enable = true,
        keymaps = {
            init_selection = "gnn",
            node_incremental = "grn",
            scope_incremental = "grc",
            node_decremental = "grm",
        },
    },
})
