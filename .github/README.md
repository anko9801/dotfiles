<div align="center">

# ❄️ dotfiles

<img src="../assets/screenshot.png" style="width: 400" />

[![built with nix](https://builtwithnix.org/badge.svg)](https://builtwithnix.org)
[![CI](https://github.com/anko9801/dotfiles/actions/workflows/ci.yaml/badge.svg)](https://github.com/anko9801/dotfiles/actions/workflows/ci.yaml)

</div>

<br />

This repository contains configurations for declaratively managing development environments across macOS, Linux, WSL, and Windows.

## Applying the configuration

> [!WARNING]
> These configurations are personalized for the [author](https://github.com/anko9801).\
> If you want to use this, fork the repository and update the configuration values (usernames, paths, etc.) before applying.

To apply these configurations, you need to have [Nix](https://github.com/NixOS/nix) installed.\
The setup script will install Nix automatically using [nix-installer](https://github.com/DeterminateSystems/nix-installer).

The following operating systems are supported:

- macOS (Apple Silicon / Intel)
- Linux
- WSL2
- Windows (via winget)

### First-time setup

Run the following command to install everything:

```sh
# macOS / Linux / WSL
curl -fsSL https://raw.githubusercontent.com/anko9801/dotfiles/master/setup | sh

# Windows (PowerShell as Administrator)
iwr https://raw.githubusercontent.com/anko9801/dotfiles/master/setup | iex
```

The setup script is interactive and will ask for confirmation at each step.

### Subsequent updates

Once set up, you can apply configuration changes with:

```sh
# macOS
darwin-rebuild switch --flake ~/dotfiles#anko-mac

# Linux / WSL
home-manager switch --flake ~/dotfiles#anko@wsl

# Update dependencies
nix flake update
```

## Why Nix?

[Nix](https://nixos.org/) is a build system that enables [reproducible builds](https://reproducible-builds.org/).\
A properly pinned Nix configuration can be rebuilt with high reproducibility even as time passes.

By using [home-manager](https://github.com/nix-community/home-manager), you can manage user-space configuration with Nix.\
By using [nix-darwin](https://github.com/nix-darwin/nix-darwin), you can manage macOS system configuration as well.

## Configuration Overview

| Component | Tools |
|-----------|-------|
| Shell | zsh, starship, zsh-abbr, fzf-tab, atuin |
| Editor | Neovim ([nixvim](https://github.com/nix-community/nixvim)) |
| Terminal | zellij |
| Theme | Tokyo Night, HackGen |
| Secrets | 1Password CLI |

### Key Features

- **Vim keybindings everywhere** - Shell, editor, and terminal all use consistent vim-style navigation
- **fzf integration** - Fuzzy search for files, history, git branches, processes
- **Modern CLI replacements** - eza, bat, fd, ripgrep, dust, procs
- **Abbreviation expansion** - Type `gst` and press Space to expand to `git status`
- **1Password integration** - SSH keys and API secrets managed via `op` CLI

## Development

You can enter the development environment using [nix-direnv](https://github.com/nix-community/nix-direnv):

```sh
echo "use flake" > .envrc
direnv allow
```

Or manually:

```sh
nix develop
```

### Available commands in devShell

```sh
nix fmt                           # Format Nix files
nix develop -c statix check .     # Lint Nix files
nix develop -c deadnix .          # Find dead code
```

## License

MIT

## References

- [momeemt/config](https://github.com/momeemt/config)
- [nix-community/home-manager](https://github.com/nix-community/home-manager)
- [nix-community/nixvim](https://github.com/nix-community/nixvim)
