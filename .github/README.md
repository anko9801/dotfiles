<div align="center">

# dotfiles

[![built with nix](https://builtwithnix.org/badge.svg)](https://builtwithnix.org)
[![Lint](https://github.com/anko9801/dotfiles/actions/workflows/lint.yaml/badge.svg)](https://github.com/anko9801/dotfiles/actions/workflows/lint.yaml)
[![Build](https://github.com/anko9801/dotfiles/actions/workflows/test.yml/badge.svg)](https://github.com/anko9801/dotfiles/actions/workflows/test.yml)

</div>

<br />

Declarative dotfiles for macOS, Linux, WSL, NixOS, and Windows using Nix Flakes.

> [!NOTE]
> Personal configuration. Fork and adapt for your own needs.

## Supported Platforms

| Platform | Integration | Command |
|----------|-------------|---------|
| macOS | nix-darwin + home-manager | `nix run .#switch` |
| NixOS | nixos + home-manager | `nix run .#switch` |
| WSL | standalone home-manager | `nix run .#switch` |
| Linux | standalone home-manager | `nix run .#switch` |
| Windows | winget + config deploy | `nix run .#windows` |

## Quick Start

```sh
# Install Nix (if not installed)
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

# Apply configuration
nix run github:anko9801/dotfiles#switch --impure
```

## Commands

```sh
nix run .#switch             # Apply configuration (auto-detect platform)
nix run .#switch -- <host>   # Apply specific host configuration
nix run .#windows            # Setup Windows config from WSL
nix run .#deploy             # Deploy to server
nix flake check              # Validate configuration
nix flake update             # Update flake inputs
nix fmt                      # Format all files
```

## Customization

Edit `config.nix`:

```nix
rec {
  # Add yourself
  users.yourname = {
    git = {
      name = "Your Name";
      email = "you@example.com";
    };
  };

  # Customize host modules
  hosts.wsl.modules = baseModules ++ [
    ./ai
    ./tools
    # Add or remove modules
  ];
}
```

## Troubleshooting

**"file not found" during build**
```sh
git add .  # Nix flakes only see git-tracked files
```

**Conflict with existing dotfiles**
```sh
# Backup and remove conflicting files in ~/.config/
mv ~/.config/foo ~/.config/foo.bak
```

**Check what will change**
```sh
nix build .#homeConfigurations.wsl.activationPackage --impure --dry-run
```
