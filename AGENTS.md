# Dotfiles

Declarative development environment powered by Nix.

## Architecture

```
flake.nix                    # Entry point (flake-parts)
config.nix                   # Users, hosts, modules, nix settings
├── system/
│   ├── hosts.nix            # Host builders (home-manager, nix-darwin, nixos)
│   ├── common.nix           # Platform detection, shared defaults
│   ├── dev-tools.nix        # Formatter, pre-commit hooks, devShell
│   ├── darwin/              # macOS system config
│   ├── nixos/               # NixOS system config
│   └── windows/             # WSL → Windows deployment
├── ai/                      # Claude, Aider
├── dev/                     # Nix tooling, Rust, Go, Python, Node
├── editor/                  # Neovim (nixvim), VS Code
├── shell/                   # Zsh, Fish, Bash, Starship
├── terminal/                # Ghostty, Zellij, tmux, Windows Terminal
├── tools/                   # Git, Yazi, Bat, CLI utils
├── desktop/                 # IME, GUI integration
├── security/                # 1Password, GPG, SSH, gitleaks
└── theme/                   # Stylix (Catppuccin Mocha)
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
- Use `lib.mkIf` for platform-specific code
- Lint with `statix check` and `deadnix`

## Flake Apps

```bash
nix run .#switch    # Apply config (auto-detects platform)
nix run .#windows   # Deploy Windows configs from WSL
nix fmt             # Format all nix files
```

## Workstation vs Server

```nix
workstation = true   # ai/ + tools/ + editor/ + terminal/
workstation = false  # minimal, no GUI
```

## Tool Selection

See [docs/tool-selection.md](docs/tool-selection.md) for:
- Evaluation criteria (must have, rejection reasons)
- Adopted/rejected tools with rationale
- Candidates under evaluation

## Reference Analysis

When user shares a URL (article, repository, dotfiles):

1. **Fetch**: Clone repo to `/tmp/` or WebFetch article
2. **Analyze**: Read all Nix files, README, structure
3. **Compare**: Look for:
   - Missing flake inputs (sops-nix, agenix, etc.)
   - Better module patterns
   - Unused Home Manager options
   - Performance/security improvements
   - New tools worth adding
4. **Prioritize**:
   - High: significant benefit, easy to implement
   - Medium: good benefit, moderate effort
   - Low: nice to have, defer
5. **Plan**: Enter plan mode with specific file changes
6. **Apply**: After approval, implement → `nix run .#fmt` → `nix run .#build`

**Rules:**
- Adapt patterns to fit this structure, don't blindly copy
- Prefer `programs.*` over raw config files
- Test before committing
