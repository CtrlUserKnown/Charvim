local dap = require('dap')
local dapui = require('dapui')

-- ui setup
dapui.setup({
    icons = { expanded = "▾", collapsed = "▸", current_frame = "▸" },
    layouts = {
        {
            elements = {
                { id = "scopes",      size = 0.35 },
                { id = "breakpoints", size = 0.15 },
                { id = "stacks",      size = 0.35 },
                { id = "watches",     size = 0.15 },
            },
            size = 40,
            position = "left",
        },
        {
            elements = {
                { id = "repl",    size = 0.5 },
                { id = "console", size = 0.5 },
            },
            size = 10,
            position = "bottom",
        },
    },
})

-- open/close ui with session
dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
dap.listeners.before.event_exited["dapui_config"]     = function() dapui.close() end

-- python
local dap_python = require('dap-python')
dap_python.setup('python3')
dap_python.test_runner = 'pytest'

-- java (jdtls built-in dap)
dap.configurations.java = {
    {
        type = 'java',
        request = 'attach',
        name = 'Attach to process',
        processId = require('dap.utils').pick_process,
    },
    {
        type = 'java',
        request = 'launch',
        name = 'Launch Java',
        mainClass = function()
            return vim.fn.input('Main class: ', '', 'file')
        end,
    },
}

-- c / c++ / swift adapter
dap.adapters.codelldb = {
    type = 'server',
    port = '${port}',
    executable = {
        command = vim.fn.stdpath('data') .. '/mason/bin/codelldb',
        args = { '--port', '${port}' },
    },
}

dap.configurations.c = {
    {
        name = 'Launch',
        type = 'codelldb',
        request = 'launch',
        program = function()
            return vim.fn.input('Executable: ', vim.fn.getcwd() .. '/', 'file')
        end,
        cwd = '${workspaceFolder}',
        stopOnEntry = false,
    },
}
dap.configurations.cpp = dap.configurations.c

-- swift uses codelldb, points to .build/debug by default
dap.configurations.swift = {
    {
        name = 'Launch Swift',
        type = 'codelldb',
        request = 'launch',
        program = function()
            return vim.fn.input('Executable: ', vim.fn.getcwd() .. '/.build/debug/', 'file')
        end,
        cwd = '${workspaceFolder}',
        stopOnEntry = false,
    },
}

-- kotlin
dap.adapters.kotlin = {
    type = 'executable',
    command = vim.fn.stdpath('data') .. '/mason/bin/kotlin-debug-adapter',
    args = {},
}

dap.configurations.kotlin = {
    {
        type = 'kotlin',
        request = 'launch',
        name = 'Launch Kotlin',
        mainClass = function()
            return vim.fn.input('Main class (e.g. com.example.MainKt): ')
        end,
        projectRoot = '${workspaceFolder}',
    },
    {
        type = 'kotlin',
        request = 'attach',
        name = 'Attach to Kotlin',
        port = 5005,
        projectRoot = '${workspaceFolder}',
    },
}

-- keymaps
local map = vim.keymap.set
map('n', '<leader>db', dap.toggle_breakpoint,                                               { desc = 'Toggle breakpoint' })
map('n', '<leader>dB', function() dap.set_breakpoint(vim.fn.input('Condition: ')) end,     { desc = 'Conditional breakpoint' })
map('n', '<leader>dc', dap.continue,                                                        { desc = 'Continue' })
map('n', '<leader>dn', dap.step_over,                                                       { desc = 'Step over' })
map('n', '<leader>di', dap.step_into,                                                       { desc = 'Step into' })
map('n', '<leader>do', dap.step_out,                                                        { desc = 'Step out' })
map('n', '<leader>dr', dap.repl.open,                                                       { desc = 'Open REPL' })
map('n', '<leader>dl', dap.run_last,                                                        { desc = 'Run last' })
map('n', '<leader>dt', dap.terminate,                                                       { desc = 'Terminate' })
map('n', '<leader>du', dapui.toggle,                                                        { desc = 'Toggle DAP UI' })
map('n', '<leader>dp', function() require('dap-python').test_method() end,                 { desc = 'Debug Python method' })
