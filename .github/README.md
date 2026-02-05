<div align="center">

# dotfiles

[![built with nix](https://builtwithnix.org/badge.svg)](https://builtwithnix.org)
[![Lint](https://github.com/anko9801/dotfiles/actions/workflows/lint.yaml/badge.svg)](https://github.com/anko9801/dotfiles/actions/workflows/lint.yaml)
[![Build](https://github.com/anko9801/dotfiles/actions/workflows/test.yml/badge.svg)](https://github.com/anko9801/dotfiles/actions/workflows/test.yml)

</div>

<br />

Personal dotfiles for declaratively managing development environments across macOS, Linux, WSL, and Windows.

> [!NOTE]
> This is a personal configuration. Feel free to fork and adapt for your own needs.

## Design Philosophy

**The goal is to minimize cognitive load.**

Cognitive load is reduced across multiple dimensions:

- **Across machines**: Nix flakes pin every dependency, so the same configuration rebuilds identically anywhere. No "works on my machine" problems.
- **Across tools**: Theme (Stylix), keybindings (Vim), and fuzzy finder (fzf) work consistently across terminal, shell, editor, and multiplexer.
- **Across time**: Self-documenting Nix code means you won't wonder why a setting exists when revisiting months later.
- **Across people**: Declarative config makes it trivial to adopt someone else's improvements—just copy the module.
- **For secrets**: 1Password handles SSH keys, git signing, and API credentials with E2E encryption—no need to manage keys yourself or sync encrypted files across machines.

The result: low friction compounds. This configuration is the result of hundreds of iterations. Fork it and get a bug-free, high-performance, productivity-boosting setup on day one.

## Setup

### Quick Start

```sh
# macOS / Linux / WSL
curl -fsSL https://raw.githubusercontent.com/anko9801/dotfiles/master/setup | sh

# Windows (PowerShell as Admin)
iwr https://raw.githubusercontent.com/anko9801/dotfiles/master/setup | iex
```

The setup script will:

1. Install Nix via [Determinate Systems installer](https://github.com/DeterminateSystems/nix-installer)
2. Clone this repository to `~/dotfiles`
3. Prompt for git config (name, email, SSH key)
4. Generate `users/$USER.nix` and apply the configuration

> [!NOTE]
> Username is detected from `$USER` environment variable (requires `--impure` flag).

### Applying Changes

```sh
# macOS
darwin-rebuild switch --impure --flake ~/dotfiles#mac

# Linux / WSL
home-manager switch --impure --flake ~/dotfiles#wsl

# Update flake inputs
nix flake update
```

## Customization

1. Fork the repository
2. Run `./setup` to generate `users/$USER.nix` with your settings
3. Modify `home/` to add or remove packages
4. Run `home-manager switch --impure --flake .#wsl`

> [!TIP]
> Add new packages to `home.packages` in the appropriate module under `home/tools/` or `home/dev/`.

## Development

Enter the development environment:

```sh
# With nix-direnv (recommended)
echo "use flake" > .envrc && direnv allow

# Or manually
nix develop
```

Available commands:

```sh
nix fmt                                        # Format Nix files
nix shell nixpkgs#statix -c statix check .     # Lint Nix files
nix shell nixpkgs#deadnix -c deadnix .         # Find dead code
```

## Troubleshooting

**Build fails with "file not found"**
- Run `git add .` to track new files before building

**Evaluation requires --impure**
- Username is detected from `$USER` environment variable

**Conflict with existing dotfiles**
- Backup and remove conflicting files in `~/.config/`

## License

MIT
