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

### Applying Changes

```sh
nix run .#switch  # Apply (auto-detects platform)
nix run .#update  # Update flake inputs
```

## Customization

1. Fork the repository
2. Run `./setup` to generate `users/$USER.nix` with your settings
3. Modify `home/` to add or remove packages
4. Run `nix run .#switch`

## Troubleshooting

**Build fails with "file not found"**
- Nix flakes only see git-tracked files. Run `git add .` before building.

**Conflict with existing dotfiles**
- Home Manager can't overwrite existing files. Backup and remove conflicting files in `~/.config/`.
