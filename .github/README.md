<div align="center">

# dotfiles

[![built with nix](https://builtwithnix.org/badge.svg)](https://builtwithnix.org)
[![Lint](https://github.com/anko9801/dotfiles/actions/workflows/lint.yaml/badge.svg)](https://github.com/anko9801/dotfiles/actions/workflows/lint.yaml)
[![Build](https://github.com/anko9801/dotfiles/actions/workflows/test.yml/badge.svg)](https://github.com/anko9801/dotfiles/actions/workflows/test.yml)

</div>

<br />

Declarative dotfiles for macOS, Linux, WSL, and NixOS using Nix Flakes.

> [!NOTE]
> Personal configuration. Fork and adapt for your own needs.

## Quick Start

```sh
# Install Nix (if not installed)
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

# Apply configuration (no clone needed)
nix run github:anko9801/dotfiles#switch --impure
```

For development, clone the repo:

```sh
git clone https://github.com/anko9801/dotfiles.git ~/dotfiles
cd ~/dotfiles
nix run .#switch --impure
```

## Commands

```sh
# From anywhere (uses latest from GitHub)
nix run github:anko9801/dotfiles#switch --impure

# From local clone
nix run .#switch --impure   # Apply configuration
nix run .#update            # Update flake inputs
nix run .#fmt               # Format all files
nix flake check --impure    # Validate configuration
```

### Server Deployment (Linux only)

```sh
nix run .#deploy <host>           # Deploy via deploy-rs
nix run .#deploy-anywhere <host>  # Fresh install via nixos-anywhere
```

## Structure

```
config.nix          # Users, hosts, modules, nix settings
flake.nix           # Flake definition

system/
├── lib.nix                  # Shared utilities
├── home-manager/
│   ├── core.nix             # Platform detection & defaults
│   └── builder.nix          # mkStandaloneHome, mkSystemHomeConfig
├── darwin/builder.nix       # mkDarwin
└── nixos/builder.nix        # mkNixOS

ai/        # Claude, LLM tools
dev/       # Go, Rust, Node, Python, Nix
editor/    # Neovim, VSCode, Helix, Zed
security/  # SSH, GPG, 1Password
shell/     # Zsh, Fish, Bash, Starship, Fzf
terminal/  # Zellij, Tmux
theme/     # Catppuccin
tools/     # Git, CLI utilities, Yazi
```

## Hosts

| Host | Platform | Type | Description |
|------|----------|------|-------------|
| `wsl` | WSL | workstation | Windows Subsystem for Linux |
| `desktop` | Linux | workstation | Native Linux desktop |
| `mac` | Darwin | workstation | macOS |
| `server` | Linux | server | Minimal server config |
| `windows` | Windows | workstation | Windows (base modules only) |

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
