<div align="center">

# dotfiles

[![built with nix](https://builtwithnix.org/badge.svg)](https://builtwithnix.org)
[![Lint](https://github.com/anko9801/dotfiles/actions/workflows/lint.yaml/badge.svg)](https://github.com/anko9801/dotfiles/actions/workflows/lint.yaml)
[![Build](https://github.com/anko9801/dotfiles/actions/workflows/test.yml/badge.svg)](https://github.com/anko9801/dotfiles/actions/workflows/test.yml)

</div>

<br />

Declarative dotfiles for macOS, Linux, WSL, NixOS, and Windows using Nix Flakes.

> [!NOTE]
> Personal configuration. Use the template to start your own:
> ```sh
> nix flake init -t github:anko9801/dotfiles
> ```

## Quick Start

```sh
# Install Nix
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

# Start from template
mkdir ~/dotfiles && cd ~/dotfiles
nix flake init -t github:anko9801/dotfiles

# Edit config.nix (replace your-username with $USER)
nix run .#switch
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

```sh
nix run .#switch             # Apply configuration (auto-detect platform)
nix run .#switch -- <host>   # Apply specific host
nix run .#windows            # Setup Windows from WSL
nix run .#deploy             # Deploy to remote server
nix fmt                      # Format all files
nix flake check --impure     # Validate configuration
```

## Troubleshooting

**"file not found" during build**
```sh
git add .  # Nix flakes only see git-tracked files
```

**Conflict with existing dotfiles**
```sh
# switch backs up conflicting files as .backup automatically
# or manually: mv ~/.config/foo ~/.config/foo.bak
```

**Check what will change**
```sh
nix build .#homeConfigurations.linux-wsl.activationPackage --impure --dry-run
```
