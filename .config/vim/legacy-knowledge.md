# Legacy Vim Configuration Knowledge

This document preserves unique knowledge and configurations from the previous vim.bak directory.

## Dein.vim Configuration

Previously used dein.vim as the plugin manager with XDG-compliant cache directory:

```vim
" XDG base directory compatible
let g:dein#cache_directory = $HOME . '/.cache/dein'

" TOML configuration files
let s:toml_dir  = $HOME . '/.vim'
let s:toml      = s:toml_dir . '/dein.toml'
let s:lazy_toml = s:toml_dir . '/dein_lazy.toml'
```

## OPAM Integration

Had OCaml/OPAM integration for development tools:

```vim
" OPAM tools integration
let s:opam_packages = ["ocp-indent", "ocp-index", "merlin"]
```

This enabled:
- **ocp-indent**: OCaml auto-indentation
- **ocp-index**: Code navigation for OCaml
- **merlin**: OCaml IDE features

## WSL Clipboard Integration

Custom WSL clipboard solution that handles multi-line yanking:

```vim
" WSL-specific clipboard integration
" Handles both single-line and multi-line yanks to Windows clipboard
" Uses temporary file for multi-line content to avoid shell escaping issues
```

Key features:
- Operator-pending mode support
- Visual mode support
- Automatic detection of WSL environment
- Handles newlines properly using temporary file

## Language-Specific Settings

### Python
- Used tabs instead of spaces (unusual for Python)
- Smart indentation with cinwords
- Tab width of 4

### JavaScript/TypeScript
- JavaScript: 4 spaces (different from TypeScript)
- TypeScript: 2 spaces
- HTML/CSS: 2 spaces

### XML
- Very narrow indentation (1 space)
- Specific for UI files (*.ui)

## Unique Configurations

### Leader Key
- Used hyphen (-) as leader key instead of common choices (space, comma)

### Visual Settings
- Relative line numbers enabled
- Virtual edit mode set to "all" (cursor can move anywhere)
- Custom popup menu colors for better visibility

### File Type Detection
- `.ui` files treated as XML
- `.sage` files treated as Python (SageMath support)

### Key Mappings
- `jj` for escape in insert mode
- Window navigation with Ctrl+hjkl
- Split creation with `ss` (horizontal) and `sv` (vertical)
- NERDTree toggle with `<leader>e`
- Tagbar toggle with `<leader>f`
- Fold level control with `<leader>0-3`

### Rainbow Parentheses
- Auto-enabled for all syntax types
- Loaded for round, square, and brace brackets

### Search Behavior
- Double Escape to clear search highlighting
- Smart case search (case-insensitive unless uppercase used)

### Persistent Undo
- XDG-compliant undo directory at `~/.cache/vim/undo`
- Automatic directory creation if missing

## Migration Notes

Most of these features have modern equivalents:
- Dein.vim → dpp.vim (current setup)
- OPAM integration → Can be added if needed for OCaml development
- WSL clipboard → Modern Vim/Neovim handle this better natively
- Rainbow parentheses → Modern alternatives like rainbow-delimiters
- Custom file type settings → Preserved in current configuration