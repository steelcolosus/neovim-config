# Neovim Configuration with LazyVim

This repository contains my Neovim configuration files, structured to utilize LazyVim for plugin management.

## Dependencies

Before installing the plugins, ensure the following dependencies are installed on your machine:

### General Dependencies

- **Neovim**: Ensure Neovim is installed. Version 0.5.0 or higher is required.
- **Git**: Used by LazyVim for plugin management.
- **Node.js**: Required for some LSP servers and plugins.
- **Python3**: Required for some Neovim plugins.
- **Nerd Fonts**: Required for better font rendering in the terminal.

  ```bash
  brew tap homebrew/cask-fonts
  brew install font-meslo-lg-nerd-font
  ```

### Specific Plugin Dependencies

#### Telescope

- **ripgrep**: For improved string searching.
  ```bash
  brew install ripgrep
  ```

#### LSP and Autocompletion

- **lspconfig**: Neovim LSP configuration.
- **mason**: Easy installation of LSP servers.
- **nvim-cmp**: Autocompletion plugin.
- **nvim-lspconfig**: Collection of configurations for built-in LSP.

#### Debugging

- **nvim-dap**: Debug Adapter Protocol client.
- **nvim-dap-python**: Python debugging.
- **nvim-dap-ui**: UI for `nvim-dap`.

#### Git Integration

- **gitsigns.nvim**: Git integration.

#### Tree-sitter

- **nvim-treesitter**: Treesitter configurations and abstraction layer.

#### Additional Plugins

- **telescope.nvim**: Fuzzy finder and more.
- **nvim-tree.lua**: File explorer.
- **nvim-autopairs**: Autopairs for brackets, quotes, etc.
- **bufferline.nvim**: Bufferline.
- **lualine.nvim**: Statusline.
- **indent-blankline.nvim**: Adds indentation guides to all lines.
- **todo-comments.nvim**: Highlight and search for TODO comments.
- **which-key.nvim**: Displays a popup with possible keybindings.
- **alpha-nvim**: Greeter dashboard.
- **auto-session**: A small automated session manager.
- **vim-maximizer**: Maximizes and restores the current window.
- **nvim-surround**: Surround text objects.
- **nvim-substitute**: Enhanced substitute commands.
- **dressing.nvim**: Improves default vim.ui interfaces.
- **trouble.nvim**: Pretty list for showing diagnostics, references, telescope results, etc.
- **nvim-copilot**: GitHub Copilot integration.

## Installation

1. Clone the repository to your Neovim configuration directory:

   ```bash
   git clone https://github.com/yourusername/neovim-config ~/.config/nvim
   ```

2. Install the dependencies mentioned above.

3. Open Neovim and install the plugins using LazyVim:

   ```bash
   nvim
   ```

   LazyVim will automatically start installing the plugins.

4. Enjoy your enhanced Neovim setup!

## Contributing

Feel free to contribute by opening issues or submitting pull requests.

## License

This project is licensed under the MIT License.
