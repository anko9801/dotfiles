---
name: nix-migrate
description: Migrate existing environment (dotfiles, packages, configs) to Nix/Home Manager. Comprehensive analysis and step-by-step migration.
---

# Nix Migration Skill

## 1. Ask Approach

Use AskUserQuestion:
- **Auto-scan** - Scan environment and suggest migration
- **Specify** - User provides files/packages

## 2. Scan Environment

### Config Files

Scan `~/.*` and `~/.config/`, skip `~/.local/state/`, `~/.cache/`.

Find non-Nix files (not symlinked to `/nix/store/`).

Classify:
- Structured (`.toml`, `.yaml`, `.json`) → migratable
- Binary → skip
- Permission 600 → credentials, warn

### Packages

List explicitly installed (not deps):

| Manager | Command |
|---------|---------|
| apt | `apt-mark showmanual` |
| brew | `brew list --installed-on-request` |
| pacman | `pacman -Qe` |
| cargo | `cargo install --list` |
| npm | `npm list -g --depth=0` |
| pip | `pip list --not-required` |
| nix-env | `nix-env -q` (migrate these!) |

## 3. Categorize & Recommend

### Configs

| Has HM module? | Frequently edited? | → Use |
|----------------|-------------------|-------|
| Yes | - | `programs.*` |
| No | No | `xdg.configFile` |
| No | Yes | `mkOutOfStoreSymlink` |

Search modules: https://home-manager-options.extranix.com/

### Packages

| Type | → Use |
|------|-------|
| CLI tools | `home.packages` |
| Configurable (git, zsh) | `programs.*` |
| Language runtimes | `mise` |
| GUI apps (macOS) | Homebrew Cask |
| System services | Keep native or NixOS module |

## 4. Present Findings

```
## Migrate to programs.*
- ~/.gitconfig → programs.git

## Migrate to home.packages
- ripgrep (apt) → pkgs.ripgrep

## Use mkOutOfStoreSymlink
- ~/.config/nvim (frequently edited)

## Skip
- ~/.config/gh/hosts.yml (credentials)

## Keep as-is
- docker (system service)
```

## 5. Create Plan & Execute

1. Use EnterPlanMode for approval
2. Create `.nix` files
3. `nix run .#fmt`
4. Test: `home-manager build`
5. Apply: `home-manager switch`
