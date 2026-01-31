# Dotfiles

Personal configuration managed with Nix + Home Manager. Works on macOS, Linux, WSL, and Windows.

This setup is declarative, reproducible, and cross-platform. One command to install, one command to update. Whether you're setting up a new machine or keeping multiple systems in sync, these dotfiles have you covered.

## Quick Start

**macOS / Linux / WSL:**
```bash
curl -fsSL https://raw.githubusercontent.com/anko9801/dotfiles/master/setup | sh
```

**Windows (PowerShell as Admin):**
```powershell
iwr https://raw.githubusercontent.com/anko9801/dotfiles/master/setup | iex
```

The setup script will:
1. Detect your OS and architecture (Apple Silicon, Intel, ARM64)
2. Install Nix (via Determinate Systems installer)
3. Clone this repository
4. Apply the appropriate configuration

## Structure

```
dotfiles/
├── flake.nix                 # Nix Flake definition
├── home.nix                  # Home Manager base config
├── setup                     # Polyglot setup script (bash + PowerShell)
├── modules/
│   ├── shell/                # zsh, starship, bash, fish
│   ├── tools/                # CLI, dev tools, neovim, claude
│   ├── platforms/            # wsl, linux, darwin, server
│   └── theme.nix             # Stylix theming (Tokyo Night)
├── darwin/                   # macOS-specific (nix-darwin, homebrew)
└── windows/                  # Windows-specific (winget, wsl.conf)
```

## Commands

```bash
# Apply configuration
darwin-rebuild switch --flake .#anko-mac    # macOS
home-manager switch --flake .#anko@linux    # Linux
home-manager switch --flake .#anko@wsl      # WSL
home-manager switch --flake .#anko@server   # Server (minimal)

# Update flake inputs
nix flake update

# Lint
nix fmt
nix develop -c statix check .
nix develop -c deadnix .
```

## Key Bindings

| Key | Action |
|-----|--------|
| `Ctrl+a` | fzf abbr selection |
| `Ctrl+r` | atuin history search |
| `Ctrl+g` | Toggle zellij UI |

## Tools

| Category | Tools |
|----------|-------|
| Shell | zsh + starship + zsh-abbr + fzf-tab + atuin |
| Editor | Neovim (nixvim) + VSCode + Zed |
| Terminal | zellij (auto-start, locked mode) |
| Git | lazygit + ghq + gh + delta + gitleaks |
| Search | ripgrep + fd + fzf |
| Files | eza + bat + dust + procs |
| Runtime | mise (Node, Python, Go, Rust, Ruby) |

## 1Password Integration

SSH keys and API secrets are managed via 1Password.

```bash
# Load API keys from 1Password
load-secrets              # From Personal vault
load-secrets Work         # From specified vault

# Quick secret read
opsecret "OpenAI/credential"
export MY_KEY=$(opsecret "Item/field")
```

### SSH Agent

- **WSL**: Uses Windows `ssh.exe` directly for 1Password SSH agent
- **macOS/Linux**: Uses native 1Password SSH agent socket

## Platform-Specific Features

### WSL
- Windows SSH agent integration via `ssh.exe`
- `clip.exe` / `pbpaste` aliases
- `wslview` for `xdg-open`
- Time sync and memory compact utilities

### macOS
- Homebrew casks for GUI apps
- Aerospace tiling window manager
- System defaults configuration

### Server
- Minimal profile (vim instead of neovim)
- Essential tools only
- Fast deployment

### Windows
- Declarative package management via winget
- Includes: PowerToys, Windows Terminal, VSCode, Zed, DevToys, etc.

## Design Principles

- **Declarative** - Everything managed by Nix or winget
- **Reproducible** - Flakes lock all dependencies
- **Cross-platform** - One setup command for all platforms
- **1Password** - Centralized credential management

## Neovim

Neovim is configured via [nixvim](https://github.com/nix-community/nixvim) with:
- LSP support for multiple languages
- Treesitter for syntax highlighting
- Telescope for fuzzy finding
- Which-key for keybinding discovery
- Tokyo Night theme via Stylix

## Contributing

Feel free to open issues or PRs if you find something useful or have suggestions!

## License

MIT
