# Declarative Package and Configuration Management

This directory contains a unified declarative system for packages and configurations.

## Structure

### packages.yaml
A comprehensive YAML file containing:
- Package definitions with installation methods
- Post-install configurations

### installer.sh
A generic installer that:
- Detects the current platform
- Installs packages using appropriate methods
- Handles post-install setup

## Package Definition Format

```yaml
packages:
  package_name:
    description: "Package description"
    macos:
      homebrew: package-name        # or homebrew: { cask: package-name }
    debian:
      apt: package-name
      github:                       # GitHub release
        repo: owner/repo
        asset_pattern: "file_%s.deb"
        type: deb
      script: "curl ... | sh"
    arch:
      pacman: package-name
      aur: package-name
    windows:
      winget: Publisher.Package
    post_install:                   # Post-installation setup
      - command1
      - command2
    # or with check:
    post_install:
      check: "command to check if configured"
      commands:
        - command1
        - command2
```

## Execution Order

1. **Platform detection** (macOS, Windows, Debian, Arch, Fedora)
2. **Package installation** with all methods
3. **Post-install commands** for each package

## Benefits

- **Unified**: Packages and configurations in one place
- **Declarative**: Everything defined in YAML
- **Ordered**: Logical execution flow
- **Flexible**: Supports checks and conditions
- **Maintainable**: Clear structure and documentation