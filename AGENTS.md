# Dotfiles

Declarative development environment powered by Nix. Write once, reproduce anywhere.

## Quick Facts

- **Platform**: Linux (WSL), macOS, NixOS
- **Shell**: Zsh (+ Fish, Bash)
- **Editor**: Neovim (nixvim)
- **Terminal**: Ghostty
- **Theme**: Catppuccin Mocha (Stylix)

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
│   ├── ai/                  # AI tools (claude, aider, ollama)
│   ├── dev/                 # Dev tools (mise, rust, go, python)
│   ├── editor/              # Neovim (nixvim)
│   ├── shell/               # Shell (zsh, fish, bash)
│   ├── terminal/            # Terminal (ghostty, tmux, zellij)
│   ├── tools/               # CLI (git, yazi, bat)
│   ├── desktop/             # Desktop (IME)
│   └── security/            # Security (1Password, GPG, SSH)
├── theme/                   # Stylix theme
└── users/                   # Per-user config
```

## Module Locations

| Config | Location | Notes |
|--------|----------|-------|
| Zsh | `home/shell/zsh/` | Modular: aliases, functions, abbr |
| Neovim | `home/editor/neovim/` | nixvim, plugins in `plugins/` |
| Git | `home/tools/git/` | git, lazygit, gh, jujutsu |
| Ghostty | `home/terminal/ghostty.nix` | Keybindings, window settings |
| Claude | `home/ai/claude/` | Hooks, agents, commands |
| AI Tools | `home/ai/` | aider, ollama, llm, shell-gpt |
| SSH | `home/security/ssh.nix` | 1Password agent integration |

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
# → includes home/ai + home/tools + home/editor + home/terminal

# workstation = false
# → minimal config, no GUI tools
```

## Critical Rules

### NEVER Do
- Store secrets in plain text (use 1Password)
- Edit files in `/nix/store/` (immutable)
- Use `home.packages` when `programs.*` exists
- Skip `nix fmt` before committing
- Create modules > 400 lines (split them)
- Auto-commit without user confirmation

### ALWAYS Do
- Run `nix flake check` before pushing
- Use `--impure` flag for home-manager (env vars needed)
- Prefer `mkOutOfStoreSymlink` for frequently edited configs
- Test on both WSL and macOS when possible
- Write all code, comments, and commits in English

## Hooks Configuration

Current hooks in `home/ai/claude/default.nix`:

| Hook | Trigger | Action |
|------|---------|--------|
| PreToolUse | Bash | Block dangerous commands (`rm -rf /`, `dd`, `mkfs`) |
| Stop | Session end (>30s) | Desktop notification |

Note: Linting is handled by pre-commit hooks (`nix develop` to install).

## Available Commands

Located in `home/ai/claude/commands/`:

| Command | Purpose |
|---------|---------|
| `/commit` | Atomic commits with conventional format |
| `/fix-ci` | Diagnose and fix CI failures |
| `/merge-main` | Safely merge main branch |
| `/create-pr` | Create pull request |
| `/test` | Generate and run tests |

## Available Agents

Located in `home/ai/claude/agents/`:

| Agent | Purpose |
|-------|---------|
| `dotfiles-optimizer` | Analyze and optimize Nix configurations |

## AI Workflow

### When Given Articles or Repositories
1. Clone the repository to `/tmp/` for analysis
2. Read all relevant files (CLAUDE.md, configs, etc.)
3. Compare with this project's structure
4. Identify improvements and differences
5. Propose specific changes

### Research Before Implementation
- Search for best practices before major changes
- Check nixpkgs for existing modules/options
- Look at similar dotfiles repos for patterns

## Development Rules

### Nix Style
- Format with `nix fmt`
- Lint with `statix check` and `deadnix`
- Keep modules to 200-400 lines
- Prefer `programs.*` over `home.packages`

### Commits
- **ALWAYS run `nix fmt && statix check . && deadnix .` before committing**
- Conventional Commits: `<type>(<scope>): <subject>`
- Split commits by concern
- Add `Assisted-by: {{agent}} (model: {{model}})` trailer

### Tool Management

| Category | Manager | Examples |
|----------|---------|----------|
| Runtimes | mise | node, python, go |
| CLI | Nix | ripgrep, fd, bat |
| Editor | nixvim | LSP, plugins |
| Secrets | 1Password | `load-secrets` |

## Flake Apps

Convenient shortcuts via `nix run`:

| App | Command | Description |
|-----|---------|-------------|
| switch | `nix run .#switch` | Apply config (auto-detects platform) |
| build | `nix run .#build` | Build without switching |
| update | `nix run .#update` | Update flake inputs |
| fmt | `nix run .#fmt` | Run treefmt |

## Common Commands

```bash
# Apply (using flake app)
nix run .#switch

# Or traditional way
home-manager switch --impure --flake ~/dotfiles#wsl

# Diff before apply
nvd diff /nix/var/nix/profiles/per-user/$USER/home-manager \
  $(home-manager build --impure --flake ~/dotfiles#wsl)

# Format & lint
nix run .#fmt && statix check . && deadnix .

# Update all inputs
nix run .#update && nix run .#switch

# Update specific input
nix flake lock --update-input nixpkgs

# Enter dev shell (with pre-commit hooks)
nix develop
```

## Troubleshooting

### Common Errors

| Error | Cause | Fix |
|-------|-------|-----|
| `error: attribute 'X' missing` | Typo or missing import | Check spelling, add import |
| `collision between` | Duplicate packages | Remove one, use `lib.mkForce` |
| `infinite recursion` | Circular dependency | Check imports, use `lib.mkDefault` |
| `hash mismatch` | Outdated lock | `nix flake update` |
| `UNFREE package` | Non-free package | Already handled via `unfreePkgs` |

### Debug Commands

```bash
# Show flake outputs
nix flake show

# Build without switching
nix build --impure .#homeConfigurations.wsl.activationPackage

# Enter dev shell
nix develop

# Garbage collect
nix-collect-garbage -d
```
