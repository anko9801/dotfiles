# Philosophy

This starter branch demonstrates the core principles behind this dotfiles
repository. It is intentionally minimal — just enough to be useful, just
enough to learn from.

## Directory structure

```
shell/    Shell configuration (zsh, bash)
editor/   Editor configuration (vim)
tools/    CLI tools (git)
```

Each directory maps to a **domain**, not a file type. Platform detection
and Home Manager defaults live directly in `flake.nix` to keep the entry
point self-contained.

## config.nix — single source of truth

All user-specific values (name, email, editor preference) live in `config.nix`.
When you fork this repository, `config.nix` is the only file you need to edit.

## 1 file = 1 tool

Each tool gets its own Nix file (`git.nix`, `vim.nix`, `zsh.nix`).
Adding a tool means creating one file and adding it to the `modules` list
in `config.nix`. Removing a tool means deleting one line.

## Growing from here

This starter branch is a subset of the `master` branch, which adds:

- **More tools**: fzf, starship, tmux, zellij, neovim, and many more
- **Multi-platform**: nix-darwin (macOS), NixOS, Windows support
- **Deferred shell init**: instant zsh startup via `zsh-defer`
- **Theme system**: Catppuccin applied consistently across all tools
- **Security**: SSH signing, gitleaks pre-commit hooks, 1Password integration
- **System library**: `system/lib.nix` for fleet-wide host management

To migrate, compare `config.nix` between branches and incrementally add
modules that interest you.
