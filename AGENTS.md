# Dotfiles

Declarative development environment powered by Nix.

## Architecture

```
flake.nix                    # Entry point
├── system/
│   ├── shared.nix           # User, versions, nix settings, helpers
│   ├── home-manager/
│   │   ├── builder.nix      # mkStandaloneHome, mkSystemHomeConfig
│   │   └── core.nix         # Base settings, platform detection
│   ├── darwin/              # macOS system config
│   └── nixos/               # NixOS system config
├── ai/                      # Claude, Aider, Ollama
├── dev/                     # mise, Rust, Go, Python
├── editor/                  # Neovim (nixvim)
├── shell/                   # Zsh, Fish, Bash
├── terminal/                # Ghostty, Zellij
├── tools/                   # Git, Yazi, Bat
├── desktop/                 # IME
├── security/                # 1Password, GPG, SSH
├── theme/                   # Stylix (Catppuccin)
└── users/                   # Per-user config
```

## Critical Rules

**NEVER:**
- Store secrets in plain text (use 1Password)
- Use `home.packages` when `programs.*` exists
- Create modules > 400 lines
- Auto-commit without user confirmation

**ALWAYS:**
- Run `nix flake check` before pushing
- Use `--impure` flag for home-manager
- Prefer `mkOutOfStoreSymlink` for frequently edited configs

## Flake Apps

```bash
nix run .#switch   # Apply config
nix run .#build    # Build only
nix run .#update   # Update inputs
nix run .#fmt      # Format code
```

## Workstation vs Server

```nix
workstation = true   # ai/ + tools/ + editor/ + terminal/
workstation = false  # minimal, no GUI
```

## Reference Analysis

When user shares a URL (article, repository, dotfiles):

1. **Fetch**: Clone repo to `/tmp/` or WebFetch article
2. **Analyze**: Read all Nix files, README, structure
3. **Compare**: Identify patterns/tools not in this repo
4. **Plan**: List improvements with priority (high/medium/low)
5. **Propose**: Enter plan mode, get user approval before implementing
