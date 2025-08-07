# Bundle - Simple Idempotent Package Manager

A minimal, idempotent package management system built with Deno.

## Design Principles

1. **Idempotent**: All operations can be run multiple times safely
2. **Simple**: Minimal abstraction, easy to understand
3. **Declarative**: Define desired state in YAML

## Architecture

```
bundle/
├── core.ts       # Core types (Package, State, Result, Provider)
├── config.ts     # Configuration parser
├── bundle.ts     # Main CLI
└── providers/    # Package manager implementations
    ├── mod.ts    # Provider registry
    ├── homebrew.ts
    ├── apt.ts
    ├── cargo.ts
    └── script.ts
```

## Core Concepts

### Package
```typescript
interface Package {
  id: string;       // Package name
  version?: string; // Optional version
}
```

### State
```typescript
enum State {
  Installed = "installed",
  Missing = "missing",
  Unknown = "unknown"
}
```

### Result (Idempotent)
```typescript
interface Result {
  success: boolean;
  changed: boolean;  // Key for idempotency
  message?: string;
}
```

### Provider Interface
```typescript
interface Provider {
  check(pkg: Package): Promise<State>;
  install(pkg: Package): Promise<Result>;
  remove(pkg: Package): Promise<Result>;
}
```

## Usage

```bash
# Install packages (idempotent)
./bundle.sh install

# Check package states
./bundle.sh check

# Remove packages (idempotent)
./bundle.sh remove
```

## Configuration

`~/.config/packages.yaml`:

```yaml
common:
  cargo:
    - ripgrep
    - fd-find
    - bat

darwin:
  homebrew:
    - git
    - neovim
    - tmux
  brew-tap:
    - homebrew/cask-fonts
  brew-cask:
    - iterm2

linux:
  apt:
    - git
    - vim
    - build-essential
```

## Idempotency

Every operation checks the current state before making changes:

1. **install**: Only installs if not already installed
2. **remove**: Only removes if currently installed
3. **check**: Read-only operation, always safe

The `changed` field in Result tracks whether any actual changes were made.

## Adding a Provider

1. Extend `BaseProvider`:

```typescript
export class MyProvider extends BaseProvider {
  readonly name = "my-provider";
  
  async check(pkg: Package): Promise<State> {
    // Check if installed
  }
  
  protected async doInstall(pkg: Package): Promise<void> {
    // Actual installation
  }
  
  protected async doRemove(pkg: Package): Promise<void> {
    // Actual removal
  }
}
```

2. Register in `providers/mod.ts`

## Bootstrap

```bash
# Run idempotent bootstrap
./bootstrap-simple

# What it does (all idempotent):
# 1. Creates directories
# 2. Installs mise
# 3. Installs deno
# 4. Links config files
# 5. Installs packages
```