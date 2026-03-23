# Charvim 🔥

Charvim is a custom Neovim configuration designed for efficiency, speed, and a seamless development experience. It features a curated selection of plugins and configurations for LSP, treesitter, status lines, and more.

## Documentation & Usage

For detailed information on how to use and customize this version of Neovim, please refer to the official wiki:

-> **[Charvim Wiki](https://github.com/CrtlUserKnown/Charvim/wiki)**

## Features

- **LSP Support:** Pre-configured Language Server Protocol for various languages.
- **Tree-sitter:** Enhanced syntax highlighting and code navigation.
- **Harpoon:** Quick file switching for improved workflow.
- **Alpha-nvim:** A beautiful and functional dashboard.
- **Tmux Integration:** Seamless navigation between Neovim and Tmux panes.

## Installation

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

## Structure

- `init.lua`: Main entry point.
- `lua/`: Modular configuration files.
  - `plugins.lua`: Plugin management via lazy.nvim.
  - `lsp-config.lua`: LSP settings.
  - `keymaps.lua`: Custom keybindings.
  - `options.lua`: General Neovim options.

---

Built by [CrtlUserKnown](https://github.com/CrtlUserKnown)
