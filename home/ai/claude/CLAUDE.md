# Claude Code Project Guide

This project uses Claude Code for AI-assisted development. This document provides context and guidelines for effective collaboration.

## Project Overview

**Purpose**: Personal dotfiles configuration for development environment setup
**Main Technologies**: Nix, Home Manager, nix-darwin, nixvim
**Key Features**: Declarative configuration, cross-platform support, reproducible environments

## Development Guidelines

### Code Style
- Use Nix for all configuration management
- Follow nixfmt formatting (run `nix fmt`)
- Keep modules small and focused (200-400 lines)
- Use statix and deadnix for linting

### Testing Approach
- Run `nix flake check` before committing
- Build configurations with `nix build --impure .#homeConfigurations.wsl.activationPackage`
- Test on both Linux and macOS when possible

### Important Commands
```bash
# Apply configuration
home-manager switch --impure --flake ~/dotfiles#wsl

# Format code
nix fmt

# Lint
nix shell nixpkgs#statix -c statix check .
nix shell nixpkgs#deadnix -c deadnix .

# Update flake inputs
nix flake update

# Show what changed
nvd diff /nix/var/nix/profiles/per-user/$USER/home-manager $(home-manager build --impure --flake ~/dotfiles#wsl)
```

## Project Structure

```
dotfiles/
├── flake.nix              # Flake definition
├── flake.lock             # Locked dependencies
├── home.nix               # Main home-manager config
├── modules/
│   ├── shell/             # zsh, starship, bash, fish
│   ├── tools/             # CLI, dev, neovim, claude
│   ├── platforms/         # wsl, linux, darwin, server
│   └── theme.nix          # Stylix theming
├── darwin/                # macOS-specific (nix-darwin)
├── windows/               # Windows (winget, wsl.conf)
└── .github/workflows/     # CI (lint, build)
```

## Tool Management

| Category | Manager | Examples |
|----------|---------|----------|
| Runtimes | mise | node, python, go, deno, bun |
| CLI tools | Nix | ripgrep, fd, bat, eza |
| Neovim | nixvim | LSP, plugins, keymaps |
| Secrets | 1Password | API keys via `op` CLI |

## Security Considerations

- Never store secrets in plain text
- Use 1Password for credential management
- SSH keys managed via 1Password SSH agent
- Use `load-secrets` function to load API keys from 1Password

## Common Tasks

### Adding a new package
1. Find the appropriate module in `modules/tools/`
2. Add package to `home.packages`
3. Run `nix fmt` and `statix check`
4. Test with `home-manager switch`

### Adding a new program with config
1. Add to `programs.<name>` in appropriate module
2. Configure settings declaratively
3. Test and commit

### Updating dependencies
```bash
nix flake update
home-manager switch --impure --flake ~/dotfiles#wsl
```

## AI Assistant Guidelines

### Core Principles
- Code like Kent Beck: simple, clear, refactor often
- Understand context first: check changed files and documents
- Explain why, not what: only comment non-obvious decisions

### Code Artifacts
- Prefer editing existing Nix modules over creating new files
- Use `programs.*` when available instead of raw `home.packages`
- Run linters before suggesting commits
- Keep configurations declarative and reproducible
- Test changes with `nix flake check`

### Commit Strategy
- **Auto-split**: When committing, analyze changes and split into logical commits if they contain multiple concerns (e.g., feature + refactor, multiple unrelated fixes)
- **Atomic commits**: Each commit should be self-contained and focused on one thing
- **Workflow**: `git reset HEAD` → `git add <files>` → `git commit` for each logical group
- Use Conventional Commits: `<type>(<scope>): <subject>`
- Types: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `chore`
- Breaking changes: `<type>!: <subject>`
- Add trailer: `Assisted-by: Claude (model: <model-name>)`
- Do not include `Co-Authored-By`
