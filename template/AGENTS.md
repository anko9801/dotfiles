# Dotfiles

Declarative development environment powered by Nix + Home Manager.

## Architecture

```
flake.nix              Entry point: inputs (nixpkgs, home-manager, stylix), outputs, apps
config.nix             Users, hosts, module lists (edit this first)
docs/
  tool-selection.md    Tool decisions and rationale (for LLM context)
system/
  hosts.nix            config.nix -> homeConfigurations builder
  common.nix           Platform detection (os/environment), defaults, HM bootstrap
  windows/
    setup.sh           Windows deployment script (run from WSL)
    winget-packages.json  Windows packages for winget import
theme/
  default.nix          Stylix: color scheme, fonts, cursor, opacity
shell/
  bash.nix             coreModule: minimal bash
  starship.nix         baseModule: cross-shell prompt
tools/
  git.nix              baseModule: git config (identity wiring demo)
editor/
  vim.nix              baseModule: vim editor
.github/
  workflows/check.yml  CI: build + cache on push/PR
renovate.json          Automated flake.lock updates (weekly)
```

## Key Concepts

### Module layers

- **coreModules** (config.nix): loaded for every host, keep minimal
- **baseModules** (config.nix): standard interactive tools + theme
- **host.modules**: per-host extras on top of baseModules
- **flakeHomeModules** (hosts.nix): flake input modules (stylix), loaded globally

### Identity wiring

```
config.nix users.*.userName/userEmail
  -> system/common.nix defaults.identity.name/email
    -> tools/git.nix reads config.defaults.identity
```

### Platform detection

`system/common.nix` exposes read-only options under `config.platform`:

- `config.platform.os` — `"linux"` | `"darwin"` | `"windows"` (auto-detected, or overridden via `hostConfig.os`)
- `config.platform.environment` — `"native"` | `"wsl"` | `"ci"` (auto-detected)

Use in modules: `lib.mkIf (config.platform.os == "windows") { ... }`

### Theming (Stylix)

`theme/default.nix` configures Stylix with a base16 color scheme (Catppuccin Mocha), fonts, cursor, and opacity. Stylix auto-applies to supported apps (starship, vim, etc.). Change the scheme by editing `base16Scheme`.

### Windows support

Windows config is built on Linux (WSL) and deployed to the Windows side:

1. Define a `windows` host in `config.nix` with `os = "windows"`
2. Run `nix run .#windows` from WSL to build and deploy
3. The setup script copies generated configs (e.g. `.gitconfig`) to Windows home
4. Windows packages are installed via `winget import` from `winget-packages.json`

### Adding a new tool

1. Create `tools/mytool.nix` (or `shell/`, `editor/`, `terminal/`, etc.)
2. Add the path to `baseModules` in `config.nix`
3. Run `nix run .#switch`

### Expanding the structure

The template is designed to grow. Add directories as needed:

```
terminal/    Ghostty, WezTerm, Zellij, tmux
dev/         Rust, Go, Python, Node, mise
security/    1Password, SSH, GPG
ai/          Claude Code, Aider
desktop/     Wayland, IME
```

### CI

GitHub Actions workflow (`.github/workflows/check.yml`) builds the default host on every push/PR.

### Dependency updates

`renovate.json` configures Renovate to auto-update `flake.lock` weekly.

### Decision records

`docs/tool-selection.md` documents tool choices and rationale. Feed this to LLMs for context-aware suggestions.

## Reference Analysis

When the user shares a URL (tech article, dotfiles repo, tool docs, etc.):

1. Fetch and read the content thoroughly
2. Extract ideas applicable to this repo: tools, patterns, workflows, config improvements
3. Adapt to fit this structure — don't blindly copy
4. Prioritize: high (significant benefit, easy) > medium > low (defer)
5. Enter plan mode with specific file changes, implement after approval

## Rules

- Prefer `programs.*` over raw `home.packages`
- Keep modules under 400 lines
- One concern per file
- Use `config.defaults.*` to share settings across modules
- Use `config.platform.*` for platform-specific logic
- Document tool decisions in `docs/tool-selection.md`
