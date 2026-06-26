local lint = require("lint")

lint.linters_by_ft = {
    lua = { "luacheck" },
    go = { "staticcheck" },
    python = { "ruff" },
    javascript = { "eslint_d" },
    typescript = { "eslint_d" },
    javascriptreact = { "eslint_d" },
    typescriptreact = { "eslint_d" },
    java = { "checkstyle" },
    kotlin = { "ktlint" },
}

vim.api.nvim_create_autocmd({ "BufWritePost", "BufEnter" }, {
    callback = function()
        pcall(lint.try_lint)
    end,
})
