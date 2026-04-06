local status_ok, configs = pcall(require, 'nvim-treesitter.configs')
if not status_ok then
  return
end

local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
parser_config.crystal = {
  install_info = {
    url = "https://github.com/crystal-lang-tools/tree-sitter-crystal",
    files = { "src/parser.c", "src/scanner.c" },
    branch = "main",
    generate_requires_npm = false,
    requires_generate_from_grammar = false,
  },
  filetype = "crystal",
}

vim.filetype.add({
  extension = {
    cr = 'crystal',
  },
})

configs.setup({
  ensure_installed = {
    "c",
    "crystal",
    "lua",
    "vim",
    "vimdoc",
    "query",
    "javascript",
    "typescript",
    "python",
    "rust",
    "go",
    "html",
    "css",
    "json",
    "markdown",
    "bash",
    "yaml",
    "toml"
  },

  sync_install = false,
  auto_install = true,
  ignore_install = {},

  highlight = {
    enable = true,
    disable = function(lang, buf)
        local max_filesize = 100 * 1024
        local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
        if ok and stats and stats.size > max_filesize then
            return true
        end
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
