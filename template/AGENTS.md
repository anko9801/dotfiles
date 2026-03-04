# Dotfiles

Declarative development environment powered by Nix + Home Manager.

## Architecture

```
flake.nix              Entry point: inputs, outputs, apps
config.nix             Users, hosts, module lists (edit this first)
system/
  hosts.nix            config.nix -> homeConfigurations builder
  common.nix           Platform detection, defaults option, HM bootstrap
shell/
  bash.nix             coreModule: minimal bash
  starship.nix         baseModule: cross-shell prompt
tools/
  git.nix              baseModule: git config (identity wiring demo)
editor/
  vim.nix              baseModule: vim editor
```

## Key Concepts

### Module layers

- **coreModules** (config.nix): loaded for every host, keep minimal
- **baseModules** (config.nix): standard interactive tools
- **host.modules**: per-host extras on top of baseModules

### Identity wiring

```
config.nix users.*.userName/userEmail
  -> system/common.nix defaults.identity.name/email
    -> tools/git.nix reads config.defaults.identity
```

### Adding a new tool

1. Create `tools/mytool.nix` (or `shell/`, `editor/`, etc.)
2. Add the path to `baseModules` in `config.nix`
3. Run `nix run .#switch`

## Rules

- Prefer `programs.*` over raw `home.packages`
- Keep modules under 400 lines
- One concern per file
- Use `config.defaults.*` to share settings across modules
