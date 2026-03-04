# dotfiles

Declarative development environment using [Nix](https://nixos.org/), [Home Manager](https://github.com/nix-community/home-manager), [nix-darwin](https://github.com/LnL7/nix-darwin), and [NixOS](https://nixos.org/).

## Quick Start (from template)

```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

mkdir ~/dotfiles && cd ~/dotfiles
nix flake init -t github:anko9801/dotfiles

# Edit config.nix (replace your-username with $USER)
nix run .#switch
```

## Structure

```
flake.nix              # Entry point (flake-parts)
config.nix             # Users, hosts, modules, nix settings
system/
├── hosts.nix          # Host builders (home-manager, nix-darwin, nixos)
├── common.nix         # Platform detection, shared defaults
├── darwin/            # macOS system modules
├── nixos/             # NixOS system modules
└── windows/           # WSL → Windows deployment
ai/                    # Claude, Aider
dev/                   # Nix tooling, Rust, Go, Python, Node
editor/                # Neovim (nixvim), VS Code
shell/                 # Zsh, Fish, Bash, Starship
terminal/              # Ghostty, Zellij, tmux, Windows Terminal
tools/                 # Git, Yazi, Bat, CLI utils
desktop/               # IME, GUI integration
security/              # 1Password, GPG, SSH, gitleaks
theme/                 # Stylix (Catppuccin Mocha)
```

## Hosts

| Host | Manager | Platform |
|------|---------|----------|
| `linux-wsl` | home-manager | WSL (x86_64) |
| `linux-desktop` | home-manager | Linux (x86_64) |
| `linux-server-{intel,arm}` | home-manager | Linux |
| `windows` | home-manager | Build on Linux, deploy via WSL |
| `mac-{arm,intel}` | nix-darwin | macOS |
| `nixos-{wsl,desktop}` | nixos | NixOS |
| `nixos-server-{intel,arm}` | nixos | NixOS servers |

## Commands

```bash
nix run .#switch          # Apply config (auto-detects platform)
nix run .#windows         # Deploy Windows configs from WSL
nix fmt                   # Format all nix files
nix flake check --impure  # Verify formatting and builds
```

## License

[MIT](LICENSE)
