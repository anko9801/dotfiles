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

This configuration is built around the idea that your development environment should feel the same no matter what machine you're on. With a single command, you get the exact same setup on macOS, Linux, or WSL.

Everything uses Vim keybindings. Whether you're navigating in the shell, editing code in Neovim, or switching panes in zellij, the muscle memory stays the same. Combined with fzf integration everywhere, you can fuzzy search through files, command history, git branches, and even running processes without thinking about which tool you're in.

Typing is kept to a minimum. Abbreviations expand as you type, ghq organizes all repositories under a consistent structure, and modern CLI tools like eza, bat, fd, and ripgrep replace their slower predecessors with sensible defaults and colorful output.

Secrets live in one place. 1Password manages SSH keys and API credentials across all devices with E2E encryption, eliminating the need to sync encrypted files or manage GPG keys.

The Tokyo Night theme ties everything together visually, applied consistently across the terminal, editor, and all CLI tools through Stylix.

### Design Decisions

| Choice | Reason |
|--------|--------|
| 1Password | E2E encrypted, single source of truth across all devices (not sops-nix) |
| zellij | Simpler configuration, built-in UI (not tmux) |
| nixvim | Declarative, reproducible, version-locked plugins (not Lua) |
| ssh.exe | No extra dependencies, native Windows SSH agent (not npiperelay) |
| zsh-abbr | Expands before execution, visible in history (not aliases) |
| atuin | SQLite-based, syncs across machines (not zsh history) |
| mise | Single tool for all runtimes (not asdf/nvm/pyenv) |
| eza/bat/fd/rg | Faster, colorful, better defaults (not ls/cat/find/grep) |
| fzf-tab | Preview files while completing (not default zsh completion) |
| lazygit | More features, better keybindings (not gitui) |
| ghq | Consistent repo structure under ~/repos (not manual clone) |
| Stylix | Unified theming across all tools (not per-app config) |
| starship | Fast, customizable, cross-shell prompt (not p10k/oh-my-zsh) |

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
