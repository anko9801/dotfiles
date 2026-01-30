# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Apply configuration
home-manager switch --flake ~/dotfiles#anko@wsl       # WSL
home-manager switch --flake ~/dotfiles#anko@linux     # Linux
home-manager switch --flake ~/dotfiles#anko@server    # Server (minimal)
sudo darwin-rebuild switch --flake ~/dotfiles#anko-mac  # macOS

# Format and lint
nix fmt
nix shell nixpkgs#statix -c statix check .
nix shell nixpkgs#deadnix -c deadnix .

# Validate
nix flake check

# Build without applying (for testing)
nix build .#homeConfigurations."anko@wsl".activationPackage
nix build .#darwinConfigurations.anko-mac.system

# Show what changed before applying
nvd diff /nix/var/nix/profiles/per-user/anko/home-manager $(home-manager build --flake ~/dotfiles#anko@wsl)

# Development shell (includes statix, deadnix, nixd, nvd)
nix develop

# Update flake inputs
nix flake update
```

## Architecture

### Configuration Flow

```
flake.nix
├── mkHome (Linux/WSL) ──► home-manager standalone
│   └── home.nix + modules/* + platforms/{wsl,linux,server}.nix
│
└── mkDarwin (macOS) ──► nix-darwin + home-manager as module
    └── darwin/configuration.nix + home.nix + modules/* + platforms/darwin.nix
```

### Platform System

Each platform module in `modules/platforms/` defines platform-specific behavior:

- **wsl.nix**: 1Password SSH agent bridge to Windows, WSL utilities, xdg-open interop
- **linux.nix**: Native Linux with systemd, Wayland support, 1Password Linux agent
- **darwin.nix**: Homebrew paths, GNU tools, 1Password macOS agent, iTerm2 integration
- **server.nix**: Minimal profile - uses vim instead of nixvim, essential tools only

Platform modules set `tools.ssh.onePasswordAgentPath` and other platform-specific options consumed by tool modules.

### Module Organization

- **modules/shell/**: zsh.nix (aliases, completions), starship.nix (prompt), bash.nix
- **modules/tools/**: Individual tool configs (neovim.nix is largest at ~1200 lines)
- **modules/services/**: syncthing (disabled on WSL)
- **modules/theme.nix**: Stylix theming with Tokyo Night, fonts (JetBrains Mono, Noto CJK)
- **darwin/**: macOS-only: homebrew.nix (casks/formulas), aerospace.nix (tiling WM), system.nix

### Key Design Decisions

1. **mise for runtimes**: Node, Python, Go, Ruby managed by mise (not Nix) for latest versions
2. **nixvim**: Neovim config in Nix rather than separate lua files
3. **Stylix**: Single source of theming across all applications
4. **1Password SSH agent**: Cross-platform credential management via platform-specific socket paths
5. **server profile**: Excludes nixvim/heavy tools for fast deployment on remote machines

## Adding Configuration

**New package**: Add to `home.packages` in the appropriate `modules/tools/*.nix`

**New program with config**: Use `programs.<name>` when available (preferred over raw packages)

**New platform-specific behavior**: Add to `modules/platforms/<platform>.nix`

**macOS-only app (GUI)**: Add to `darwin/homebrew.nix` under `casks`
