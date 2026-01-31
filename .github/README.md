<div align="center">

# ❄️ dotfiles

<img src="../assets/screenshot.png" style="width: 400" />

[![built with nix](https://builtwithnix.org/badge.svg)](https://builtwithnix.org)
[![CI](https://github.com/anko9801/dotfiles/actions/workflows/ci.yaml/badge.svg)](https://github.com/anko9801/dotfiles/actions/workflows/ci.yaml)

</div>

<br />

This repository contains configurations for declaratively managing development environments across macOS, Linux, WSL, and Windows.

## Setup

The following operating systems are supported:

- macOS (Apple Silicon / Intel)
- Linux
- WSL2
- Windows (via winget)

### First-time setup

```sh
# macOS / Linux / WSL
curl -fsSL https://raw.githubusercontent.com/anko9801/dotfiles/master/setup | sh

# Windows (PowerShell as Administrator)
iwr https://raw.githubusercontent.com/anko9801/dotfiles/master/setup | iex
```

The setup script will:

1. Install Nix via [Determinate Systems installer](https://github.com/DeterminateSystems/nix-installer)
2. Clone this repository
3. Prompt for your configuration (username, git email, etc.)
4. Generate `user.nix` and apply the configuration

For automation, you can use flags:

```sh
./setup --user myname --git-name "My Name" --git-email me@example.com --non-interactive
```

### Subsequent updates

```sh
# macOS
darwin-rebuild switch --flake ~/dotfiles

# Linux / WSL
home-manager switch --flake ~/dotfiles

# Update dependencies
nix flake update
```

## Why Nix?

[Nix](https://nixos.org/) is a build system that enables [reproducible builds](https://reproducible-builds.org/).\
A properly pinned Nix configuration can be rebuilt with high reproducibility even as time passes.

By using [home-manager](https://github.com/nix-community/home-manager), you can manage user-space configuration with Nix.\
By using [nix-darwin](https://github.com/nix-darwin/nix-darwin), you can manage macOS system configuration as well.

## Configuration Overview

This configuration is built around the idea that your development environment should feel the same no matter what machine you're on. With a single command, you get the exact same setup on macOS, Linux, or WSL.

Everything uses Vim keybindings. Whether you're navigating in the shell, editing code in Neovim, or switching panes in zellij, the muscle memory stays the same. Combined with fzf integration everywhere, you can fuzzy search through files, command history, git branches, and even running processes without thinking about which tool you're in.

Typing is kept to a minimum. Abbreviations expand as you type, ghq organizes all repositories under a consistent structure, and modern CLI tools like eza, bat, fd, and ripgrep replace their slower predecessors with sensible defaults and colorful output.

Secrets live in one place. 1Password manages SSH keys and API credentials across all devices with E2E encryption, eliminating the need to sync encrypted files or manage GPG keys.

The Tokyo Night theme ties everything together visually, applied consistently across the terminal, editor, and all CLI tools through Stylix.

| Component | Choice | Reason |
|-----------|--------|--------|
| Shell | zsh, zsh-abbr, fzf-tab, atuin | Abbreviations expand before execution, visible in history. SQLite-based history syncs across machines. |
| Editor | Neovim (nixvim) | Declarative, reproducible, version-locked plugins (not Lua config) |
| Terminal | zellij | Simpler configuration, built-in UI (not tmux) |
| Theme | Tokyo Night, Stylix | Unified theming across all tools (not per-app config) |
| Secrets | 1Password | SSH keys, git signing, API keys all in one place with E2E encryption (not sops-nix/GPG) |
| Runtimes | mise | Single tool for all runtimes (not asdf/nvm/pyenv) |
| Python | uv | Fast package manager and venv (not pip/venv) |
| CLI | eza, bat, fd, rg, dust, procs | Faster, colorful, better defaults (not ls/cat/find/grep/du/ps) |
| Git UI | lazygit | More features, better keybindings (not gitui) |
| Git diff | delta, difftastic | Side-by-side, syntax highlighted, structural diffs (not diff) |
| Repo management | ghq | Consistent structure under ~/repos (not manual clone) |
| Task runner | just | Simple, cross-platform (not make) |
| Prompt | starship | Fast, customizable, cross-shell (not p10k/oh-my-zsh) |
| Package search | nix-index, comma | Run any package without installing (not apt/brew search) |

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
