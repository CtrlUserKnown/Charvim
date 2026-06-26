# Charvim 🔥

Charvim is a custom Neovim configuration designed for efficiency, speed, and a seamless development experience. Built on Neovim 0.12+.

For detailed information on how to use and customize this configuration, refer to the official wiki:

-> **[Charvim Wiki](https://github.com/CrtlUserKnown/Charvim/wiki)**

## Project Structure

```text
Charvim/
├── nvim/
│   ├── after/
│   │   └── ftplugin/
│   │       ├── cobol.lua           # COBOL-specific settings
│   │       └── make.lua            # Makefile-specific settings
│   ├── colors/
│   │   └── noir-cat.lua            # Custom noir-cat colorscheme
│   ├── lua/
│   │   ├── img/
│   │   │   └── charVim.txt         # ASCII art for the dashboard
│   │   ├── alpha-config.lua        # Dashboard configuration
│   │   ├── autoclose.lua           # Auto-closing brackets and quotes
│   │   ├── completion-config.lua   # nvim-cmp completion config
│   │   ├── dap-config.lua          # Debugger configuration
│   │   ├── harpoon-config.lua      # Harpoon keymaps and setup
│   │   ├── keymaps.lua             # Custom keybindings
│   │   ├── lint-config.lua         # Linter configuration (nvim-lint)
│   │   ├── lsp-config.lua          # LSP settings and handlers
│   │   ├── options.lua             # General Neovim options
│   │   ├── plugins.lua             # Plugin definitions via lazy.nvim
│   │   ├── rename-config.lua       # Find & replace / rename panel
│   │   ├── statusline.lua          # Custom mode-aware statusline
│   │   ├── theme-switcher.lua      # Runtime theme cycling with persistence
│   │   └── treesitter-config.lua   # Treesitter setup
│   └── init.lua                    # Main entry point
├── .github/
│   └── workflows/
│       ├── config_test.yml         # CI: headless Neovim config test
│       └── setup_test.yml          # CI: install script test
├── .gitignore
├── CHANGELOG
├── LICENSE
├── README.md                       # This file
└── setup.sh                        # Install script
```

## What's inside?

### Core Config

*   **init.lua**: The main entry point. Loads all modules in order — options, keymaps, plugins, and post-plugin configs.
*   **options.lua**: General editor settings like line numbers, tabs, scrolloff, clipboard, and cursor shape.
*   **keymaps.lua**: Custom keybindings. Includes leader-key shortcuts, line movement, file runners for Python, Java, and HTML, and terminal shortcuts.
*   **plugins.lua**: All plugin definitions managed by `lazy.nvim`.

### LSP & Completion

*   **lsp-config.lua**: LSP setup for ten language servers — all managed through Mason and the native `vim.lsp` API. Includes inlay hints, diagnostics config, and build-system detection for Java and Kotlin projects.

    | Server | Language(s) |
    |---|---|
    | `lua_ls` | Lua |
    | `gopls` | Go |
    | `pyright` | Python |
    | `ts_ls` | TypeScript / JavaScript |
    | `jdtls` | Java (Maven, Gradle, Ant) |
    | `kotlin_language_server` | Kotlin |
    | `clangd` | C / C++ / Objective-C |
    | `sourcekit-lsp` | Swift / Objective-C |
    | `tinymist` | Typst |
    | `lemminx` | XML |

*   **completion-config.lua**: Autocompletion powered by `nvim-cmp` with `luasnip` snippets, LSP source, and buffer source.

### AI

*   **avante.nvim**: AI-assisted code chat and editing powered by Anthropic Claude (`claude-haiku-4-5`). Use `:AvanteAsk` to chat about code or `:AvanteEdit` to edit with AI assistance. Requires `ANTHROPIC_API_KEY` set in your environment or a `.env` file at the repo root.

### UI & Themes

*   **statusline.lua**: Custom statusline with mode-aware highlights that dynamically adapt to the active colorscheme.
*   **alpha-config.lua**: Startup dashboard with ASCII art, quick-access buttons, and a footer showing the date and Neovim version.
*   **theme-switcher.lua**: Theme picker with Telescope live-preview — browse themes and see them applied before confirming. The last-used theme is persisted and restored on startup. Cycle with `:ThemeSelect` or switch directly with `:Theme <name>`.
*   **noir-cat.lua**: A custom dark colorscheme in `nvim/colors/`.

### Tools

*   **rename-config.lua**: Find & replace / rename panel built with `nui.nvim`. Live ripgrep search with file preview, single-occurrence or project-wide replacement, and automatic LSP rename when the cursor is on a known symbol. Open with `<leader>S` or `:Find`.
*   **multicursor.lua**: Homebrew multi-cursor implementation (no plugin dependency). Add cursors above/below with `Ctrl+Up` / `Ctrl+Down`, or enter multi-cursor mode with `Ctrl+N` and then navigate with `j`/`k`. Exit with `Esc`.
*   **harpoon-config.lua**: Harpoon2 setup for quick file switching. Navigate with `Alt+1` through `Alt+5`, or cycle with `Alt+N` / `Alt+P`.
*   **dap-config.lua**: Debug Adapter Protocol setup for Python, Java, C/C++, and Kotlin. Opens a UI automatically when a session starts.
*   **lint-config.lua**: Linter configuration via `nvim-lint`. Linters are installed via Mason.

    | Filetype | Linter |
    |---|---|
    | Lua | `luacheck` |
    | Go | `staticcheck` |
    | Python | `ruff` |
    | JavaScript / TypeScript | `eslint_d` |
    | Java | `checkstyle` |
    | Kotlin | `ktlint` |

*   **treesitter-config.lua**: Treesitter parsers for syntax highlighting, indentation, and incremental selection. Includes auto tag closing for HTML/JSX.
*   **autoclose.lua**: Auto-closes brackets, quotes, and parentheses in insert and command mode. Also wraps visual selections.

### Filetype

*   **after/ftplugin/cobol.lua**: COBOL-specific settings — 8-space tabs, column markers at 7 and 73, and absolute line numbers.
*   **after/ftplugin/make.lua**: Makefile-specific settings.

## Installation

Run the install script:

```bash
bash <(curl -s https://raw.githubusercontent.com/CrtlUserKnown/Charvim/main/setup.sh)
```

The script automatically installs missing system dependencies before setting up the config. Supported package managers:

| OS / Distro | Package manager |
|---|---|
| macOS | `brew` |
| Fedora / RHEL | `dnf` |
| Debian / Ubuntu | `apt` |
| Arch Linux | `pacman` |

Or manually:

1. **Backup your existing configuration:**
   ```bash
   mv ~/.config/nvim ~/.config/nvim.bak
   ```

2. **Clone the repository:**
   ```bash
   git clone https://github.com/CrtlUserKnown/Charvim.git ~/.config/nvim
   ```

3. **Launch Neovim:**
   ```bash
   nvim
   ```

Plugins will be installed automatically via `lazy.nvim` on first launch.

## Requirements

- Neovim 0.12+
- Git
- A [Nerd Font](https://www.nerdfonts.com/) for icons
- `ripgrep` — used by Telescope live grep and `rename-config`
- `fd` — used by Telescope file finder
- `python3` — for DAP Python support
- `make` — required to build `avante.nvim`
- `node` — required by Mason-managed LSP servers (TypeScript, etc.)
- `ANTHROPIC_API_KEY` — set in your environment or a `.env` file at the repo root (for avante.nvim AI features)

---

Built by [CrtlUserKnown](https://github.com/CrtlUserKnown)
