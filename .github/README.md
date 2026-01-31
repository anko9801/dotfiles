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
3. Prompt for git configuration (name, email, SSH key)
4. Generate `user.nix` and apply the configuration

> [!NOTE]
> Username is automatically detected from `$USER`. The `--impure` flag is required for this.

> [!WARNING]
> When forking, edit `user.nix` to set your git configuration and SSH hosts.

For automation, you can use flags:

```sh
./setup --git-name "My Name" --git-email me@example.com --non-interactive
```

### Subsequent updates

```sh
# macOS
darwin-rebuild switch --impure --flake ~/dotfiles#mac

# Linux / WSL
home-manager switch --impure --flake ~/dotfiles#wsl

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
| Theme | Stylix, Tokyo Night | Unified theming across all tools (not per-app config) |
| Terminal | Ghostty, Windows Terminal (zellij) | GPU-accelerated emulators, simpler multiplexer (not tmux) |
| Shell | zsh, zsh-abbr, fzf-tab, atuin | POSIX-compliant with fish-like abbr/fzf (not fish) |
| Prompt | starship | Fast, customizable, cross-shell (not p10k/oh-my-zsh) |
| Runtimes | mise | Single tool for all runtimes including uv for Python (not asdf/nvm/pyenv/pip) |
| Editor | Neovim (nixvim) | Declarative, reproducible, version-locked plugins (not Lua config) |
| CLI | eza, bat, fd, rg, zoxide, dust, procs | Faster, colorful, better defaults (not ls/cat/find/grep/cd/du/ps) |
| Git | lazygit, delta, difftastic, ghq | TUI, syntax-highlighted diffs, structural diffs, consistent repo layout |
| Secrets | 1Password | SSH keys, git signing, API keys all in one place with E2E encryption (not sops-nix/GPG) |
| Task runner | just | Simple, cross-platform (not make) |

## Structure

```
dotfiles/
├── flake.nix           # Flake definition and configurations
├── home.nix            # Main home-manager config
├── user.nix            # User-specific settings (git, SSH hosts)
├── modules/
│   ├── shell/          # zsh, starship
│   ├── tools/          # CLI, dev tools, neovim
│   └── platforms/      # wsl, linux, darwin, server
├── darwin/             # macOS-specific (nix-darwin)
└── windows/            # Windows (winget, wsl.conf)
```

## Customization

To fork and adapt this configuration:

1. Fork the repository
2. Edit `user.nix` to set your git name, email, and SSH key
3. Modify `modules/` to add or remove packages
4. Run `home-manager switch --impure --flake .#wsl`

> [!TIP]
> Add new packages to `home.packages` in the appropriate module under `modules/tools/`.

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

## Troubleshooting

**Build fails with "file not found"**
- Run `git add .` to track new files before building

**Evaluation requires --impure**
- Username is detected from `$USER` environment variable, which requires impure evaluation

**Conflict with existing dotfiles**
- Backup and remove conflicting files in `~/.config/`

## License

MIT
