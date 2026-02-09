<div align="center">

# dotfiles

[![built with nix](https://builtwithnix.org/badge.svg)](https://builtwithnix.org)
[![Lint](https://github.com/anko9801/dotfiles/actions/workflows/lint.yaml/badge.svg)](https://github.com/anko9801/dotfiles/actions/workflows/lint.yaml)
[![Build](https://github.com/anko9801/dotfiles/actions/workflows/test.yml/badge.svg)](https://github.com/anko9801/dotfiles/actions/workflows/test.yml)

</div>

<br />

Personal dotfiles for declaratively managing development environments across macOS, Linux, WSL, and Windows.

Designed to minimize cognitive load: reproducible across machines, consistent across tools, self-documenting code.

> [!NOTE]
> This is a personal configuration. Feel free to fork and adapt for your own needs.

## Features

| Category | Tools |
|----------|-------|
| Shell | Zsh, Fish, Bash |
| Editor | Neovim (nixvim) |
| Terminal | Ghostty, Zellij |
| Theme | Catppuccin Mocha (Stylix) |
| AI | Claude Code, Aider, Ollama |
| Dev | mise (node, python, go), Rust |

## Targets

| Target | Platform | Manager |
|--------|----------|---------|
| `wsl` | WSL | home-manager |
| `desktop` | Linux | home-manager |
| `server` | Linux (minimal) | home-manager |
| `mac` / `mac-intel` | macOS | nix-darwin |
| `nixos-wsl` | NixOS on WSL | NixOS |
| `nixos-desktop` | NixOS | NixOS |
| `nixos-server` | NixOS (minimal) | NixOS |

## Setup

### Quick Start

```sh
# macOS / Linux / WSL
curl -fsSL https://raw.githubusercontent.com/anko9801/dotfiles/master/setup | sh
```

**Windows**: Install WSL first (`wsl --install`), then run the above command from WSL.

The setup script will:

1. Install Nix via [Determinate Systems installer](https://github.com/DeterminateSystems/nix-installer)
2. Clone this repository to `~/dotfiles`
3. Prompt for git config (name, email, SSH key)
4. Generate `users/$USER.nix` and apply the configuration

### Applying Changes

```sh
# macOS / Linux / WSL
nix run .#switch  # Apply (auto-detects platform)
nix run .#update  # Update flake inputs

# Windows (from WSL)
nix run .#setup-windows  # Build and deploy Windows config
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
