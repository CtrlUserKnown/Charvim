return
{
    -- Nvim Surround
    {
        "kylechui/nvim-surround",
        version = "*",
        event = "VeryLazy",
        config = function()
            require("nvim-surround").setup({})
        end
    },

    -- Multi-cursor support
    {
        "mg979/vim-visual-multi",
        branch = "master",
        lazy = false,
    },

    -- Vim-Tmux-Navigator
    {
        "christoomey/vim-tmux-navigator",
        cmd = {
            "TmuxNavigateLeft",
            "TmuxNavigateDown",
            "TmuxNavigateUp",
            "TmuxNavigateRight",
            "TmuxNavigatePrevious",
        },
        keys = {
            { "<c-h>", "<cmd>TmuxNavigateLeft<cr>" },
            { "<c-j>", "<cmd>TmuxNavigateDown<cr>" },
            { "<c-k>", "<cmd>TmuxNavigateUp<cr>" },
            { "<c-l>", "<cmd>TmuxNavigateRight<cr>" },
            { "<c-\\>", "<cmd>TmuxNavigatePrevious<cr>" },
        },
    },

    -- Harpoon2
    {
        'ThePrimeagen/harpoon',
        branch = 'harpoon2',
        dependencies = { 'nvim-lua/plenary.nvim' },
        config = function()
            require('harpoon-config')
        end
    },

    -- Rosé Pine
    {
        'rose-pine/neovim',
        name = 'rose-pine',
        priority = 1000,
        config = function()
            require('rose-pine').setup({
                variant = 'main',
                disable_background = true,
                disable_float_background = true,
                disable_italics = false,
                highlight_groups = {
                        CursorLineNr = { fg = 'gold', bold = true }
                }
            })
            vim.cmd('colorscheme rose-pine')
        end
    },

    -- Treesitter with nvim-ts-autotag bundled so parsers are ready before autotag attaches
    {
        'nvim-treesitter/nvim-treesitter',
        branch = 'main',
        build = ':TSUpdate',
        dependencies = {
            {
                'windwp/nvim-ts-autotag',
                config = function()
                    require('nvim-ts-autotag').setup({
                        opts = {
                            enable_close = true,
                            enable_rename = true,
                            enable_close_on_slash = true,
                        },
                    })
                end,
            },
        },
    },

    -- Mason (LSP/DAP/Linter installer)
    {
        'williamboman/mason.nvim',
        config = function()
            require('mason').setup({
                ui = {
                    icons = {
                        package_installed = "✓",
                        package_pending = "➜",
                        package_uninstalled = "✗"
                    }
                }
            })
        end,
    },

    {
        'williamboman/mason-lspconfig.nvim',
        dependencies = { 'williamboman/mason.nvim', 'neovim/nvim-lspconfig' },
        config = function()
            local lsp_config = require('lsp-config')
            require('mason-lspconfig').setup({
                ensure_installed = {
                    'lua_ls',
                    'pyright',
                    'ts_ls',
                    'jdtls',
                },
                automatic_installation = true,
                handlers = lsp_config.handlers,
            })
        end,
    },

    -- Project management
    {
        "ahmedkhalf/project.nvim",
        config = function()
            require("project_nvim").setup({
                detection_methods = { "pattern", "lsp" },
                patterns = { ".git", "Makefile", "package.json", "pom.xml", "build.gradle", "Cargo.toml" },
                show_hidden = false,
                silent_chdir = true,
            })
        end,
    },

    -- Telescope and file browser extension
    {
        'nvim-telescope/telescope.nvim',
        dependencies = {
            'nvim-lua/plenary.nvim',
            'nvim-telescope/telescope-file-browser.nvim',
            'ahmedkhalf/project.nvim',
        },
        config = function()
            local telescope = require('telescope')
            local actions = require('telescope.actions')
            local action_state = require('telescope.actions.state')

            telescope.setup({
                defaults = {
                    prompt_prefix = ' 🔎  ',
                    selection_caret = '▸',
                    file_ignore_patterns = {
                        "%.git/",
                        "%DS_Store$"
                    },
                    mappings = {
                        i = {
                            ["<C-.>"] = function(prompt_bufnr)
                                local picker = action_state.get_current_picker(prompt_bufnr)
                                local finder = picker.finder
                                finder.hidden = not finder.hidden
                                picker:refresh(require('telescope.finders').new_oneshot_job(
                                    vim.tbl_flatten({
                                        "fd",
                                        "--type", "f",
                                        finder.hidden and "--hidden" or "--no-hidden",
                                        "--color", "never"
                                    }),
                                    picker.finder.entry_maker
                                ))
                            end,
                        },
                    },
                },
                pickers = {
                    find_files = {
                        hidden = true,
                    },
                },
                extensions = {
                    file_browser = {
                        hidden = true,
                        hijack_netrw = true,
                    },
                    projects = {},
                },
            })

            pcall(telescope.load_extension, 'file_browser')
            pcall(telescope.load_extension, 'projects')
        end,
    },

    -- Which-key
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        opts = {
            preset = "modern",
        },
        config = function()
            local wk = require("which-key")
            wk.setup({
                preset = "modern",
            })

            wk.add({
                { "<leader>r", group = "Refactor" },
                { "<leader>w", desc = "Save file" },
                { "<leader>q", desc = "Save and quit" },
                { "<leader>Q", desc = "Quit without saving" },
                { "<leader>e", desc = "File explorer" },
                { "<leader>v", desc = "File explorer" },
                { "<leader>p", desc = "Projects" },
            })
        end,
    },

    -- DAP
    {
        'mfussenegger/nvim-dap',
        dependencies = {
            'rcarriga/nvim-dap-ui',
            'nvim-neotest/nvim-nio',
            'jay-babu/mason-nvim-dap.nvim',
            'mfussenegger/nvim-dap-python',
        },
        config = function()
            require('dap-config')
        end,
    },

    -- Mason DAP installer
    {
        'jay-babu/mason-nvim-dap.nvim',
        dependencies = { 'williamboman/mason.nvim', 'mfussenegger/nvim-dap' },
        config = function()
            require('mason-nvim-dap').setup({
                ensure_installed = {
                    'python',
                    'javadbg',
                    'codelldb',
                },
                automatic_installation = true,
            })
        end,
    },

    -- noice.nvim
    {
        "folke/noice.nvim",
        event = "VeryLazy",
        dependencies = {
            "MunifTanjim/nui.nvim",
        },
        opts = {
            cmdline = {
                enabled = true,
                view = "cmdline_popup",
                format = {
                    cmdline = { icon = ":" },
                    search_down = { icon = "🔍 ⌄" },
                    search_up = { icon = "🔍 ⌃" },
                    filter = { icon = "$" },
                    lua = { icon = "☾" },
                    help = { icon = "?" },
                },
            },
            messages = {
                enabled = false,
            },
            popupmenu = {
                enabled = true,
                backend = "nui",
            },
            lsp = {
                override = {
                    ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
                    ["vim.lsp.util.stylize_markdown"] = true,
                    ["cmp.entry.get_documentation"] = true,
                },
            },
            presets = {
                bottom_search = true,
                command_palette = true,
                long_message_to_split = true,
            },
        },
    },

    -- GitHub Copilot
    {
        "zbirenbaum/copilot.lua",
        cmd = "Copilot",
        event = "InsertEnter",
        config = function()
            require("copilot").setup({
                panel = {
                    enabled = true,
                    auto_refresh = false,
                    keymap = {
                        jump_prev = "[[",
                        jump_next = "]]",
                        accept = "<CR>",
                        refresh = "gr",
                        open = "<M-CR>"
                    },
                    layout = {
                        position = "bottom",
                        ratio = 0.4
                    },
                },
                suggestion = {
                    enabled = true,
                    auto_trigger = true,
                    debounce = 75,
                    keymap = {
                        accept = "<M-l>",
                        accept_word = false,
                        accept_line = false,
                        next = "<M-k>",
                        prev = "<M-j>",
                        dismiss = "<C-]>",
                    },
                },
                filetypes = {
                    yaml = false,
                    markdown = false,
                    help = false,
                    gitcommit = false,
                    gitrebase = false,
                    hgcommit = false,
                    svn = false,
                    cvs = false,
                    ["."] = false,
                },
                copilot_node_command = 'node',
                server_opts_overrides = {},
            })
        end,
    },

    -- Copilot CMP source
    {
        "zbirenbaum/copilot-cmp",
        dependencies = { "zbirenbaum/copilot.lua" },
        config = function()
            require("copilot_cmp").setup()
        end
    },

    -- alpha-nvim dashboard
    {
        "goolord/alpha-nvim",
        config = function ()
            require('alpha-config')
        end
    },

    -- Typst Preview
    {
        'chomosuke/typst-preview.nvim',
        ft = 'typst',
        version = '1.*',
        build = function()
            require('typst-preview').update()
        end,
        opts = {},
        config = function()
            vim.api.nvim_create_user_command('TP', 'TypstPreview', { desc = 'Start Typst preview' })
            vim.api.nvim_create_user_command('TS', 'TypstPreviewStop', { desc = 'Stop Typst preview' })
            vim.api.nvim_create_user_command('TU', 'TypstPreviewUpdate', { desc = 'Update Typst preview' })
        end
    },

    -- Completion plugins
    'hrsh7th/nvim-cmp',
    'hrsh7th/cmp-buffer',
    'hrsh7th/cmp-path',
    'hrsh7th/cmp-cmdline',
    'hrsh7th/cmp-nvim-lsp',
    'hrsh7th/cmp-nvim-lua',

    -- Snippet engine
    'L3MON4D3/LuaSnip',
    'saadparwaiz1/cmp_luasnip',
}
