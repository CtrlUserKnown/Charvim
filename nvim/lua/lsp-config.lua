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
    update_in_insert = true,
    severity_sort = true,
    float = {
        border = "rounded",
        source = "if_many",
        header = "",
        prefix = "",
    },
})

local capabilities = require("cmp_nvim_lsp").default_capabilities()

local function mason_cmd(name)
    local path = vim.fn.stdpath('data') .. '/mason/bin/' .. name
    if vim.fn.executable(path) == 1 then
        return { path }
    end
    return { name }
end

vim.lsp.config('lua_ls', {
    cmd = mason_cmd('lua-language-server'),
    filetypes = { 'lua' },
    root_markers = { '.luarc.json', '.luarc.jsonc', '.luacheckrc', '.stylua.toml', 'selene.toml', 'selene.yml', '.git' },
    capabilities = capabilities,
    on_attach = on_attach,
    settings = {
        Lua = {
            runtime = { version = 'LuaJIT' },
            workspace = {
                checkThirdParty = false,
                library = vim.api.nvim_get_runtime_file("", true),
            },
            diagnostics = { globals = { 'vim' } },
            telemetry = { enable = false },
        },
    },
})
vim.lsp.enable('lua_ls')

vim.lsp.config('gopls', {
    cmd = mason_cmd('gopls'),
    filetypes = { 'go', 'gomod' },
    root_markers = { 'go.mod', '.git' },
    capabilities = capabilities,
    on_attach = on_attach,
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
})
vim.lsp.enable('gopls')

vim.lsp.config('tinymist', {
    cmd = mason_cmd('tinymist'),
    filetypes = { 'typst' },
    root_markers = { '.git' },
    capabilities = capabilities,
    on_attach = on_attach,
    settings = {
        exportPdf = "onSave",
        outputPath = "$root/$dir/$name",
    },
})
vim.lsp.enable('tinymist')

vim.lsp.config('clangd', {
    cmd = mason_cmd('clangd'),
    filetypes = { 'c', 'cpp', 'objc', 'objcpp' },
    root_markers = { '.clangd', 'compile_commands.json', '.git' },
    capabilities = capabilities,
    on_attach = on_attach,
})
vim.lsp.enable('clangd')

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

local function jdtls_workspace(root_dir)
    local workspace = vim.fn.stdpath('cache') .. '/jdtls'
    if root_dir then
        workspace = workspace .. '/' .. vim.fn.fnamemodify(root_dir, ':t')
    else
        workspace = workspace .. '/default'
    end
    return workspace
end

vim.lsp.config('jdtls', {
    cmd = function(dispatchers, config)
        local path = vim.fn.stdpath('data') .. '/mason/bin/jdtls'
        local exe = vim.fn.executable(path) == 1 and path or 'jdtls'
        local data_dir = jdtls_workspace(config.root_dir)
        return vim.lsp.rpc.start({ exe, '-data', data_dir }, dispatchers, {
            cwd = config.cmd_cwd,
            env = config.cmd_env,
            detached = config.detached,
        })
    end,
    filetypes = { 'java' },
    root_markers = { 'build.xml', 'pom.xml', 'build.gradle', 'build.gradle.kts', 'settings.gradle', 'settings.gradle.kts', '.git' },
    capabilities = capabilities,
    on_attach = on_attach,
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
                    profile = "GoogleStyle",
                },
            },
        },
    },
})
vim.lsp.enable('jdtls')

vim.lsp.config('pyright', {
    cmd = mason_cmd('pyright'),
    filetypes = { 'python' },
    root_markers = { 'pyproject.toml', 'setup.py', 'setup.cfg', 'requirements.txt', '.git' },
    capabilities = capabilities,
    on_attach = on_attach,
})
vim.lsp.enable('pyright')

vim.lsp.config('ts_ls', {
    cmd = mason_cmd('typescript-language-server'),
    filetypes = { 'javascript', 'typescript', 'javascriptreact', 'typescriptreact', 'vue' },
    root_markers = { 'package.json', 'tsconfig.json', 'jsconfig.json', '.git' },
    capabilities = capabilities,
    on_attach = on_attach,
})
vim.lsp.enable('ts_ls')

vim.lsp.config('lemminx', {
    cmd = mason_cmd('lemminx'),
    filetypes = { 'xml' },
    root_markers = { '.git' },
    capabilities = capabilities,
    on_attach = on_attach,
})
vim.lsp.enable('lemminx')

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
            local workspace_dir = jdtls_workspace(root)
            vim.lsp.stop_client(vim.lsp.get_clients({ name = 'jdtls' }))
            vim.fn.system('rm -rf ' .. workspace_dir)
            vim.notify("Cleaned JDTLS workspace for " .. vim.fn.fnamemodify(root, ':t'), vim.log.levels.INFO)
            vim.notify("Restart Neovim or run :LspStart to reinitialize", vim.log.levels.INFO)
        end, vim.tbl_extend('force', opts, { desc = 'Clean JDTLS workspace cache' }))
    end
})

return {
    on_attach = on_attach,
}
