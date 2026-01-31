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
- **Across tools**: Stylix applies your theme consistently across terminal, editor, and CLI tools—change it once, change it everywhere. Vim keybindings and fzf work the same in shell, editor, and multiplexer.
- **Across time**: Self-documenting Nix code means you won't wonder why a setting exists when revisiting months later.
- **Across people**: Declarative config makes it trivial to adopt someone else's improvements—just copy the module.
- **For secrets**: 1Password handles SSH keys, git signing, and API credentials with E2E encryption—no need to manage keys yourself or sync encrypted files across machines.

The result: minimal configuration that just works—no bugs, high performance, improved productivity.

## Implementation

Configuration follows the [XDG Base Directory Specification](https://specifications.freedesktop.org/basedir-spec/latest/). Nix garbage collection runs weekly automatically.

Security is layered: destructive commands require confirmation, secrets are caught before commit, and sensitive commands are filtered from shell history.

Environments are automatic: project-specific shells activate on `cd`, and any Nixpkgs command can run without installation via comma.

Code quality is enforced at the flake level with unified formatting and static analysis in CI.

| Component | Choice | Reason |
|-----------|--------|--------|
| Theme | Stylix | Unified theming across all tools |
| Terminal | Ghostty, Windows Terminal | GPU-accelerated, native feel |
| Multiplexer | zellij | Simpler config, better defaults than tmux |
| Shell | zsh, zsh-abbr, fzf-tab, atuin | POSIX-compliant with fish-like UX |
| Prompt | starship | Fast, customizable, cross-shell |
| Runtimes | mise | Single tool for node/python/go/ruby/java |
| Editor | Neovim (nixvim) | Declarative, reproducible plugins |
| CLI | eza, bat, fd, rg, zoxide, dust, procs, trash-cli | Modern replacements with sane defaults |
| Git | lazygit, delta, difftastic, ghq, gitleaks | TUI, semantic diffs, pre-commit secret scanning |
| Secrets | 1Password | E2E encrypted SSH keys, git signing, API keys |
| Dev env | direnv, nix-direnv, comma | Auto-activate per-project, run any Nixpkgs command |
| Formatting | treefmt (nixfmt, shfmt, yamlfmt) | Unified formatting across languages |
| Task runner | just | Simple, cross-platform |

## Setup

Supported platforms: macOS (Apple Silicon / Intel), Linux, WSL2, Windows

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

### Subsequent updates

```sh
# macOS
darwin-rebuild switch --impure --flake ~/dotfiles#mac

# Linux / WSL
home-manager switch --impure --flake ~/dotfiles#wsl

# Update dependencies
nix flake update
```

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

The entry point is `flake.nix`, which defines configurations for each platform. Shared settings live in `home.nix` and `modules/`, while `user.nix` holds personal settings like git name and SSH hosts.

## Customization

1. Fork the repository
2. Edit `user.nix` to set your git name, email, and SSH key
3. Modify `modules/` to add or remove packages
4. Run `home-manager switch --impure --flake .#wsl`

> [!TIP]
> Add new packages to `home.packages` in the appropriate module under `modules/tools/`.

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
nix fmt                           # Format Nix files
nix develop -c statix check .     # Lint Nix files
nix develop -c deadnix .          # Find dead code
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
