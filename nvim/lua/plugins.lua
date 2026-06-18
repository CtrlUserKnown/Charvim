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

    -- Multi-cursor support (replaced by homebrew multicursor.lua)
    -- {
    --     "mg979/vim-visual-multi",
    --     branch = "master",
    --     lazy = false,
    -- },

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
        end
    },

    -- Tokyo Night
    {
        'folke/tokyonight.nvim',
        lazy = false,
        priority = 1000,
        opts = {
            style = 'night',
            transparent = true,
        },
    },

    -- Catppuccin
    {
        'catppuccin/nvim',
        name = 'catppuccin',
        lazy = false,
        priority = 1000,
        opts = {
            flavour = 'mocha',
            transparent_background = true,
        },
    },

    -- Gruvbox
    {
        'ellisonleao/gruvbox.nvim',
        lazy = false,
        priority = 1000,
        opts = {
            transparent_mode = true,
        },
    },

    -- Treesitter
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

    -- Mason (LSP servers, linters, DAP installers)
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

    -- Telescope
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
                    file_ignore_patterns = { "%.git/", "%DS_Store$" },
                    mappings = {
                        i = {
                            ["<C-.>"] = function(prompt_bufnr)
                                local picker = action_state.get_current_picker(prompt_bufnr)
                                local finder = picker.finder
                                finder.hidden = not finder.hidden
                                picker:refresh(require('telescope.finders').new_oneshot_job(
                                    vim.tbl_flatten({
                                        "fd", "--type", "f",
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
                    find_files = { hidden = true },
                },
                extensions = {
                    file_browser = { hidden = true, hijack_netrw = true },
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
        opts = { preset = "modern" },
        config = function()
            local wk = require("which-key")
            wk.setup({ preset = "modern" })
            wk.add({
                { "<leader>r", group = "Refactor" },
                { "<leader>w", desc = "Save file" },
                { "<leader>q", desc = "Save and quit" },
                { "<leader>Q", desc = "Quit without saving" },
                { "<leader>e", desc = "File explorer" },
                { "<leader>v", desc = "File explorer" },
                { "<leader>p", desc = "Projects" },
                { "<leader>g", desc = "Live grep" },
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

    -- Mason DAP
    {
        'jay-babu/mason-nvim-dap.nvim',
        dependencies = { 'williamboman/mason.nvim', 'mfussenegger/nvim-dap' },
        config = function()
            require('mason-nvim-dap').setup({
                ensure_installed = { 'python', 'javadbg', 'codelldb' },
                automatic_installation = true,
            })
        end,
    },

    -- noice.nvim
    {
        "folke/noice.nvim",
        event = "VeryLazy",
        dependencies = { "MunifTanjim/nui.nvim" },
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
            messages = { enabled = false },
            popupmenu = { enabled = false },
            lsp = {
                override = {
                    ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
                    ["vim.lsp.util.stylize_markdown"] = true,
                },
            },
            presets = {
                bottom_search = true,
                command_palette = true,
                long_message_to_split = true,
            },
        },
    },

    -- avante.nvim (local AI code completion with Ollama + Qwen 2.5 Coder)
    {
        "yetone/avante.nvim",
        event = "VeryLazy",
        build = "make",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "stevearc/dressing.nvim",
            "nvim-telescope/telescope.nvim",
            "nvim-tree/nvim-web-devicons",
            "MunifTanjim/nui.nvim",
            {
                "HakonHarnes/img-clip.nvim",
                event = "VeryLazy",
                opts = {
                    default = {
                        embed_image_as_base64 = false,
                    },
                },
            },
        },
        config = function()
            vim.g.plenary_curl_bin_path = "/usr/bin/curl"
            require("avante").setup({
                provider = "ollama",
                providers = {
                    ollama = {
                        model = "qwen2.5-coder:3b",
                    },
                },
                hints = { enabled = true },
                suggestion = { enabled = true, debounce = 75, mode = "inline" },
                mappings = {
                    suggestion = {
                        accept = "<S-Tab>",
                        next = "<M-]>",
                        dismiss = "<C-]>",
                    },
                },
                behaviour = {
                    auto_suggestions = true,
                    enable_cursor_planning = false,
                },
            })
        end,
    },

    -- alpha-nvim dashboard
    {
        "goolord/alpha-nvim",
        config = function()
            require('alpha-config')
        end
    },

    -- Typst Preview
    {
        'chomosuke/typst-preview.nvim',
        ft = 'typst',
        version = '1.*',
        build = function() require('typst-preview').update() end,
        opts = {},
        config = function()
            vim.api.nvim_create_user_command('TP', 'TypstPreview', { desc = 'Start Typst preview' })
            vim.api.nvim_create_user_command('TS', 'TypstPreviewStop', { desc = 'Stop Typst preview' })
            vim.api.nvim_create_user_command('TU', 'TypstPreviewUpdate', { desc = 'Update Typst preview' })
        end
    },

    -- Linting (nvim-lint)
    {
        "mfussenegger/nvim-lint",
        config = function()
            require('lint-config')
        end,
    },

    -- nvim-cmp core + sources
    "hrsh7th/nvim-cmp",
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-buffer",

    -- Snippet engine (kept for DAP/LSP snippet expansion)
    'L3MON4D3/LuaSnip',
}
