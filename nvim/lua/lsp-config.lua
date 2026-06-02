local function add_word_to_dictionary(word, client_name)
    if client_name == "ltex" then
        local params = {
            command = "ltex.addToDictionary",
            arguments = {
                {
                    words = {
                        ["en-US"] = { word }
                    }
                }
            }
        }
        vim.lsp.buf.execute_command(params)
    end

    if client_name == "typos_lsp" then
        local config_path = vim.fn.expand("~/.config/typos.toml")
        vim.notify("Add custom typos config at " .. config_path, vim.log.levels.INFO)
    end
end

local on_attach = function(client, bufnr)
    local opts = { noremap = true, silent = true, buffer = bufnr }

    if client:supports_method('textDocument/inlayHint') then
        vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
    end

    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
    vim.keymap.set('n', 'go', vim.lsp.buf.type_definition, opts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
    vim.keymap.set('n', 'gs', vim.lsp.buf.signature_help, opts)
    vim.keymap.set('n', '<leader>lr', vim.lsp.buf.rename, opts)
    vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
    vim.keymap.set('n', '<leader>le', vim.diagnostic.open_float, opts)
    vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
    vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)

    vim.keymap.set('n', '<leader>ih', function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }), { bufnr = bufnr })
    end, { buffer = bufnr, desc = 'Toggle inlay hints' })

    vim.keymap.set('n', '<leader>ig', function()
        local word = vim.fn.expand('<cword>')
        add_word_to_dictionary(word, client.name)
        vim.notify("Added '" .. word .. "' to dictionary", vim.log.levels.INFO)
    end, vim.tbl_extend('force', opts, { desc = 'Ignore word (add to dictionary)' }))

    vim.keymap.set('n', '<leader>di', function()
        local diag = vim.diagnostic.get(0, { lnum = vim.fn.line('.') - 1 })
        print(vim.inspect(diag))
    end, vim.tbl_extend('force', opts, { desc = 'Inspect diagnostics at cursor' }))
end

local function filter_diagnostics(diagnostics)
    return vim.tbl_filter(function(diagnostic)
        if diagnostic.message:match("sentence is %d+ words long") then return false end
        if diagnostic.message:match("paragraph is %d+ words long") then return false end
        if diagnostic.message:match("This sentence") then return false end
        return true
    end, diagnostics)
end

local original_set = vim.diagnostic.set
vim.diagnostic.set = function(namespace, bufnr, diagnostics, opts)
    diagnostics = filter_diagnostics(diagnostics)
    original_set(namespace, bufnr, diagnostics, opts)
end

vim.diagnostic.config({
    virtual_text = { source = "if_many" },
    signs = true,
    underline = true,
    update_in_insert = false,
    severity_sort = true,
    float = {
        border = "rounded",
        source = "if_many",
        header = "",
        prefix = "",
    },
})

local lspconfig_ok, lspconfig = pcall(require, 'lspconfig')
if not lspconfig_ok then
    return { on_attach = on_attach, handlers = {} }
end

local capabilities = vim.lsp.protocol.make_client_capabilities()
local cmp_nvim_lsp_ok, cmp_nvim_lsp = pcall(require, 'cmp_nvim_lsp')
if cmp_nvim_lsp_ok then
    capabilities = cmp_nvim_lsp.default_capabilities()
end

vim.lsp.config('sourcekit-lsp', {
    cmd = { 'sourcekit-lsp' },
    filetypes = { 'swift', 'c', 'cpp', 'objective-c', 'objective-cpp' },
    root_markers = { 'Package.swift', 'compile_commands.json', '.git' },
    capabilities = capabilities,
    on_attach = on_attach,
})

vim.api.nvim_create_autocmd('FileType', {
    pattern = { 'swift', 'c', 'cpp', 'objective-c', 'objective-cpp' },
    callback = function()
        vim.lsp.enable('sourcekit-lsp')
    end,
})

local handlers = {
    function(server_name)
        lspconfig[server_name].setup {
            on_attach = on_attach,
            capabilities = capabilities,
        }
    end,

    ['lua_ls'] = function()
        lspconfig.lua_ls.setup {
            on_attach = on_attach,
            capabilities = capabilities,
            settings = {
                Lua = {
                    runtime = {
                        version = 'LuaJIT',
                    },
                    workspace = {
                        checkThirdParty = false,
                        -- exposes the full nvim runtime to lua_ls so vim.* is recognised
                        library = vim.api.nvim_get_runtime_file("", true),
                    },
                    diagnostics = {
                        globals = { 'vim' },
                    },
                    telemetry = {
                        enable = false,
                    },
                },
            },
        }
    end,

    ['gopls'] = function()
        lspconfig.gopls.setup {
            on_attach = on_attach,
            capabilities = capabilities,
            settings = {
                gopls = {
                    analyses = { unusedparams = true, shadow = true },
                    staticcheck = true,
                    gofumpt = true,
                    hints = {
                        assignVariableTypes = true,
                        compositeLiteralFields = true,
                        compositeLiteralTypes = true,
                        constantValues = true,
                        functionTypeParameters = true,
                        parameterNames = true,
                        rangeVariableTypes = true,
                    },
                },
            },
        }
    end,

    ['tinymist'] = function()
        lspconfig.tinymist.setup {
            on_attach = on_attach,
            capabilities = capabilities,
            settings = {
                exportPdf = "onSave",
                outputPath = "$root/$dir/$name",
            },
        }
    end,

    ['jdtls'] = function()
        local function get_jdtls_workspace(root_dir)
            local project_name = vim.fn.fnamemodify(root_dir, ':p:h:t')
            return vim.fn.stdpath('cache') .. '/jdtls/' .. project_name
        end

        lspconfig.jdtls.setup(vim.tbl_deep_extend('force', {
            on_attach = on_attach,
            capabilities = capabilities,
        }, {
            filetypes = { 'java' },
            root_dir = lspconfig.util.root_pattern(
                'build.xml', 'pom.xml', 'build.gradle', 'build.gradle.kts',
                'settings.gradle', 'settings.gradle.kts', '.git'
            ),
            cmd_env = {
                JDTLS_WORKSPACE = function()
                    local root = vim.fs.root(0, {
                        'build.xml', 'pom.xml', 'build.gradle', 'build.gradle.kts',
                        'settings.gradle', 'settings.gradle.kts', '.git'
                    })
                    if root then return get_jdtls_workspace(root) end
                    return vim.fn.stdpath('cache') .. '/jdtls/default'
                end
            },
            on_attach = function(client, bufnr)
                on_attach(client, bufnr)
                vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
            end,
            settings = {
                java = {
                    eclipse = { downloadSources = true },
                    configuration = { updateBuildConfiguration = "interactive" },
                    maven = { downloadSources = true, updateSnapshots = false },
                    project = {
                        referencedLibraries = {
                            "lib/**/*.jar", "**/lib/*.jar",
                            vim.fn.expand("~/.m2/repository/**/*.jar"),
                            vim.fn.expand("~/.gradle/caches/**/*.jar"),
                            "target/**/*.jar", "build/libs/**/*.jar", "dist/**/*.jar",
                        },
                    },
                    inlayHints = { parameterNames = { enabled = "all" } },
                    implementationsCodeLens = { enabled = true },
                    referencesCodeLens = { enabled = true },
                    sources = { organizeImports = { starThreshold = 9999, staticStarThreshold = 9999 } },
                    codeGeneration = {
                        toString = { template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}" },
                        hashCodeEquals = { useJava7Objects = true },
                        useBlocks = true,
                    },
                    completion = {
                        favoriteStaticMembers = {
                            "org.junit.Assert.*", "org.junit.Assume.*",
                            "org.junit.jupiter.api.Assertions.*", "org.junit.jupiter.api.Assumptions.*",
                            "org.junit.jupiter.api.DynamicContainer.*", "org.junit.jupiter.api.DynamicTest.*",
                            "org.mockito.Mockito.*", "org.mockito.ArgumentMatchers.*", "org.mockito.Answers.*",
                        },
                        filteredTypes = { "com.sun.*", "io.micrometer.shaded.*", "java.awt.*", "jdk.*", "sun.*" },
                        importOrder = { "java", "javax", "com", "org" },
                    },
                    format = {
                        enabled = true,
                        settings = {
                            url = vim.fn.stdpath("config") .. "/java-format.xml",
                            profile = "GoogleStyle",
                        },
                    },
                },
            },
        }))
    end,
}

vim.api.nvim_create_autocmd("FileType", {
    pattern = "java",
    callback = function()
        local root = vim.fs.root(0, {
            'build.xml', 'pom.xml', 'build.gradle', 'build.gradle.kts',
            'settings.gradle', 'settings.gradle.kts',
        })
        if not root then return end

        if vim.fn.filereadable(root .. '/pom.xml') == 1 then
            vim.b.java_build_system = 'Maven'
            vim.b.java_build_file  = 'pom.xml'
        elseif vim.fn.filereadable(root .. '/build.gradle') == 1 or
               vim.fn.filereadable(root .. '/build.gradle.kts') == 1 then
            vim.b.java_build_system = 'Gradle'
            vim.b.java_build_file  = vim.fn.filereadable(root .. '/build.gradle') == 1
                and 'build.gradle' or 'build.gradle.kts'
        elseif vim.fn.filereadable(root .. '/build.xml') == 1 then
            vim.b.java_build_system = 'Ant'
            vim.b.java_build_file  = 'build.xml'
        end
        vim.b.java_project_root = root
    end
})

vim.api.nvim_create_autocmd("FileType", {
    pattern = "java",
    callback = function(args)
        local bufnr = args.buf
        local opts = { buffer = bufnr, noremap = true, silent = true }

        local function run_build_cmd(cmd)
            if cmd then vim.cmd('split | terminal ' .. cmd) end
        end

        local function get_cmd(maven_cmd, gradle_cmd, ant_cmd)
            local bs   = vim.b.java_build_system
            local root = vim.b.java_project_root
            if not bs or not root then
                vim.notify("No build system detected", vim.log.levels.WARN)
                return nil
            end
            if bs == 'Maven'  then return 'cd ' .. root .. ' && ' .. maven_cmd end
            if bs == 'Gradle' then return 'cd ' .. root .. ' && ' .. gradle_cmd end
            if bs == 'Ant'    then return 'cd ' .. root .. ' && ' .. ant_cmd end
        end

        vim.keymap.set('n', '<leader>jb', function()
            run_build_cmd(get_cmd('mvn compile', './gradlew build', 'ant compile'))
        end, vim.tbl_extend('force', opts, { desc = 'Build Java project' }))

        vim.keymap.set('n', '<leader>jt', function()
            run_build_cmd(get_cmd('mvn test', './gradlew test', 'ant test'))
        end, vim.tbl_extend('force', opts, { desc = 'Run Java tests' }))

        vim.keymap.set('n', '<leader>jc', function()
            run_build_cmd(get_cmd('mvn clean', './gradlew clean', 'ant clean'))
        end, vim.tbl_extend('force', opts, { desc = 'Clean Java project' }))

        vim.keymap.set('n', '<leader>jw', function()
            local root = vim.b.java_project_root
            if not root then
                vim.notify("No Java project detected", vim.log.levels.WARN)
                return
            end
            local project_name  = vim.fn.fnamemodify(root, ':p:h:t')
            local workspace_dir = vim.fn.stdpath('cache') .. '/jdtls/' .. project_name
            vim.cmd('LspStop jdtls')
            vim.fn.system('rm -rf ' .. workspace_dir)
            vim.notify("Cleaned JDTLS workspace for " .. project_name, vim.log.levels.INFO)
            vim.notify("Restart Neovim or run :LspStart to reinitialize", vim.log.levels.INFO)
        end, vim.tbl_extend('force', opts, { desc = 'Clean JDTLS workspace cache' }))
    end
})

return {
    on_attach = on_attach,
    handlers  = handlers,
}
