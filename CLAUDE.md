# Dotfiles

Declarative development environment powered by Nix. Write once, reproduce anywhere.

## Architecture

```
flake.nix                    # Entry point
├── system/
│   ├── common.nix           # Shared config (username, versions, unfreePkgs)
│   ├── linux/               # Home Manager standalone
│   ├── darwin/              # macOS (nix-darwin)
│   └── nixos/               # NixOS
├── home/                    # User config (home-manager modules)
│   ├── core.nix             # Base settings
│   ├── dev/                 # Dev tools (mise, rust, go, python)
│   ├── editor/              # Neovim (nixvim)
│   ├── shell/               # Shell (zsh, fish, bash)
│   ├── terminal/            # Terminal (ghostty, tmux, zellij)
│   ├── tools/               # CLI (git, yazi, claude)
│   ├── desktop/             # Desktop (IME)
│   └── security/            # Security (1Password, GPG, SSH)
├── theme/                   # Stylix theme (catppuccin-mocha)
└── users/                   # Per-user config
```

## Configuration Targets

| Target | Use Case | Command |
|--------|----------|---------|
| `wsl` | WSL (home-manager) | `home-manager switch --impure --flake .#wsl` |
| `linux-desktop` | Linux desktop | `home-manager switch --impure --flake .#linux-desktop` |
| `server` | Server (minimal) | `home-manager switch --impure --flake .#server` |
| `mac` | macOS | `darwin-rebuild switch --flake .#mac` |
| `nixos-wsl` | NixOS on WSL | `nixos-rebuild switch --flake .#nixos-wsl` |
| `nixos-desktop` | NixOS desktop | `nixos-rebuild switch --flake .#nixos-desktop` |

## Workstation vs Server

```nix
# workstation = true (default)
# → includes home/tools + home/editor + home/terminal

# workstation = false
# → minimal config, no GUI tools
```

## Development Rules

### Nix Style
- Format with `nix fmt`
- Lint with `statix check` and `deadnix`
- Keep modules to 200-400 lines
- Prefer `programs.*` over `home.packages`

### Commits
- Conventional Commits: `<type>(<scope>): <subject>`
- Split commits by concern
- Add `Assisted-by: Claude (model: <model-name>)` trailer

### Tool Management
| Category | Manager | Examples |
|----------|---------|----------|
| Runtimes | mise | node, python, go |
| CLI | Nix | ripgrep, fd, bat |
| Editor | nixvim | LSP, plugins |
| Secrets | 1Password | `load-secrets` |

## Common Commands

```bash
# Apply
home-manager switch --impure --flake ~/dotfiles#wsl

# Diff
nvd diff /nix/var/nix/profiles/per-user/$USER/home-manager \
  $(home-manager build --impure --flake ~/dotfiles#wsl)

# Format & lint
nix fmt && statix check . && deadnix .

# Update
nix flake update && home-manager switch --impure --flake ~/dotfiles#wsl
```
