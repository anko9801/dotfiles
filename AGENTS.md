# Dotfiles

Declarative development environment powered by Nix.

## Architecture

```
flake.nix              Entry point (flake-parts): inputs, apps, formatter, checks
config.nix             Users, hosts, modules, moduleSets, nix settings
system/
  hosts.nix            config.nix -> homeConfigurations/darwinConfigurations/nixosConfigurations
  common.nix           Platform detection (os/environment), shared defaults, HM bootstrap
  dev-tools.nix        Formatter (treefmt), pre-commit hooks (git-hooks), devShell
  darwin/              macOS system modules (homebrew, aerospace)
  nixos/               NixOS system modules (desktop, wsl, server, comin)
  windows/             WSL -> Windows deployment (setup.sh, winget-packages.json)
ai/                    Claude, Aider
dev/                   Nix tooling, Rust, Go, Python, Node, mise
editor/                Neovim (nixvim), VS Code
shell/                 Zsh, Fish, Bash, Starship
terminal/              Ghostty, Zellij, tmux, Windows Terminal
tools/                 Git, Yazi, Bat, CLI utils
desktop/               IME, GUI integration
security/              1Password, GPG, SSH, gitleaks
theme/                 Stylix (Catppuccin Mocha)
docs/                  Tool selection rationale, design philosophy
```

## Key Concepts

### config.nix structure

```nix
{
  users.<name>     = { git = { name, email, sshKey }; editor; };
  baseModules      = [ ... ];           # standard interactive tools
  moduleSets       = { workstation; server; };  # reusable module bundles
  hosts.<name>     = { system; manager; modules; ... };
  defaultHosts     = { darwin; nixos; wsl; linux; };
  nixSettings      = { settings; gc; gcSchedule; };
  versions         = { home; nixos; darwin; };
}
```

- `manager`: `"home-manager"` | `"nix-darwin"` | `"nixos"` — selects the builder in hosts.nix
- `moduleSets.workstation` = baseModules ++ ai/ + tools/ + editor/ + terminal/
- `moduleSets.server` = baseModules ++ minimal tools (vim, git, bat, tmux)

### Module layers

- **coreModules** (hosts.nix): loaded for every host — common.nix, nix.nix, defaults.nix, bash.nix
- **baseModules** (config.nix): standard interactive tools + theme
- **moduleSets** (config.nix): workstation/server presets that include baseModules
- **host.modules**: per-host module set (typically a moduleSet + extras)
- **flakeHomeModules** (hosts.nix): flake input HM modules (nix-index-database, nixvim, stylix, agent-skills), loaded globally

### Platform detection

`system/common.nix` exposes read-only options under `config.platform`:

- `config.platform.os` — `"linux"` | `"darwin"` | `"windows"` (auto-detected, or overridden via `hostConfig.os`)
- `config.platform.environment` — `"native"` | `"wsl"` | `"ci"` (auto-detected)

Use in modules: `lib.mkIf (config.platform.os == "linux") { ... }`

### Identity wiring

```
config.nix users.*.git.name/email
  -> system/common.nix defaults.identity.name/email
    -> modules read config.defaults.identity
```

### Windows support

Windows config is built on Linux (WSL) and deployed to the Windows side:

1. `windows` host in config.nix with `os = "windows"`
2. `nix run .#windows` builds config and copies to Windows home (.gitconfig, VS Code, Windows Terminal, komorebi, kanata)
3. Fonts installed, winget packages imported

## Rules

- Prefer `programs.*` over raw `home.packages`
- Keep modules under 400 lines
- One concern per file
- Use `config.defaults.*` to share settings across modules
- Use `config.platform.*` for platform-specific logic
- Lint with `statix check` and `deadnix`, format with `nix fmt`
- Test with `nix flake check --impure` before pushing
- Document tool decisions in `docs/tool-selection.md`
- Never claim something is "missing" without reading the actual file first
- Do not trust subagent summaries for absence claims — verify with Read or Grep
- When unsure, say "I didn't find X" not "X is missing"

## Reference Analysis

When the user shares a URL (tech article, dotfiles repo, tool docs, etc.):

1. Fetch the content (clone repos to `/tmp/`, WebFetch for articles)
2. Extract ideas applicable to this repo: tools, patterns, workflows, config improvements
3. Adapt to fit this structure — don't blindly copy
4. Prioritize: high (significant benefit, easy) > medium > low (defer)
5. Enter plan mode with specific file changes, implement after approval

## Commands

```bash
nix run .#switch    # Apply config (auto-detects platform)
nix run .#windows   # Deploy Windows configs from WSL
nix run .#deploy    # Deploy to remote servers
nix fmt             # Format all files
```
