# Vim Plugin History

This document preserves the plugin configurations from the legacy dein.vim setup for reference.

## Plugin Manager Evolution

1. **dein.vim** (Legacy) - Used previously with TOML configuration
2. **dpp.vim** (Current) - Modern Deno/TypeScript-based plugin manager

## Legacy Plugin List (dein.toml)

### Core Utilities
- **vimproc.vim** - Asynchronous execution library
- **vim-sonictemplate** - Template engine for file creation
- **tagbar** + **tagbar-javascript.vim** - Code outline viewer
- **vim-quickrun** - Asynchronous code execution

### Fuzzy Finder
- **fzf** + **fzf.vim** - Command-line fuzzy finder integration
  - Custom commands: FZFFileList, FZFMru
  - Ripgrep integration for fast searching

### Git Integration
- **vim-fugitive** - Git commands within Vim
- **vim-gitgutter** - Shows git diff in the sign column
- **gina.vim** - Asynchronous Git client
- **committia.vim** - Better commit message editing
- **nerdtree-git-plugin** - Git status in NERDTree

### Color Themes
Multiple themes were configured:
- vim-deus, sonokai, everforest, melange
- onedark.vim, iceberg.vim, vim-colors-solarized
- gruvbox, gruvbox-material, ayu-vim
- **rainbow_parentheses.vim** - Colorful nested parentheses

### UI Enhancements
- **lightline.vim** - Lightweight statusline
- **vim-airline** + **vim-airline-themes** - Advanced statusline/tabline
- **vim-floaterm** - Floating terminal windows
- **goyo.vim** - Distraction-free writing mode
- **TweetVim** - Twitter client in Vim
- **vim-startify** - Start screen with sessions
- **numbers.vim** - Better line numbers

### Key Mappings & Motion
- **clever-f.vim** - Extended f, F, t, T motions
- **vim-easymotion** - Fast motions with 2-character search
- **vim-easy-replace** - Enhanced replace operations
- **yankround.vim** - Cycle through yank history
- **vim-fakeclip** - Clipboard support
- **vim-submode** - Create custom submodes

### Text Objects & Operators
- **vim-operator-user** - Define custom operators
- **vim-operator-surround** - Surround text objects
- **vim-textobj-user** - Define custom text objects
- Various text objects:
  - entire, line, function, python, between
  - indent, latex, multiblock, blockwise
  - parameter, comment

### Session Management
- **vim-obsession** - Continuously updated sessions
- **vim-startify** - Session management on start screen

### Other Features
- **auto-pairs** - Auto-close brackets and quotes
- **vim-tmux-navigator** - Seamless tmux/vim navigation
- **open-browser.vim** - Open URLs in browser
- **vim-commentary** - Comment/uncomment code
- **suda.vim** - Edit files with sudo
- **vim-bracketed-paste** - Better paste handling

## Legacy Plugin List (dein_lazy.toml)

### Modern Vim Infrastructure
- **denops.vim** - Deno-based plugin platform

### Fuzzy Finder Evolution
- **ddu.vim** - Next-generation fuzzy finder
  - Multiple UIs: ff, filer
  - Sources: file, buffer, rg, make, colorscheme
  - Filters: substring matcher, relative matcher
  - Extensive customization

### Auto-completion Evolution
- **ddc.vim** - Next-generation auto-completion
  - Sources: vim-lsp, vsnip, omni, buffer, file, around
  - UI: native, inline, pum.vim
  - LSP integration with vim-lsp
  - Snippet support with vim-vsnip

### LSP Support
- **vim-lsp** + **vim-lsp-settings** - Language Server Protocol
- **ddc-vim-lsp** - LSP source for ddc.vim
- **denops-signature_help** - Function signatures
- **denops-popup-preview** - Documentation preview

### Context-aware Features
- **context_filetype.vim** - Detect embedded languages
- **vim-precious** - Switch filetype automatically

## Migration Notes

### From dein.vim to dpp.vim
- TOML configuration → TypeScript configuration
- Lazy loading → More sophisticated lazy loading
- VimL hooks → TypeScript/Deno integration

### Plugin Replacements
- unite.vim → denite.nvim → ddu.vim
- neocomplete → deoplete.nvim → ddc.vim
- ctrlp.vim → fzf.vim → ddu.vim

### Modern Alternatives
Many plugins have modern replacements in Neovim:
- vim-gitgutter → gitsigns.nvim
- NERDTree → neo-tree.nvim
- tagbar → aerial.nvim
- vim-airline → lualine.nvim
- rainbow_parentheses.vim → rainbow-delimiters.nvim

### Key Features to Preserve
1. **Fuzzy finding** with ripgrep integration
2. **Git integration** with multiple tools
3. **LSP support** for modern development
4. **Auto-completion** with multiple sources
5. **Text objects** for efficient editing
6. **Session management** for workspace persistence