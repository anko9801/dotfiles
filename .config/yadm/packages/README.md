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
  # Organized by OS -> Package Manager
  macos:
    homebrew:
      - package-name1
      - package-name2
    homebrew_cask:
      - cask-package
    git_clone:
      - name: tool-name
        repo: "https://github.com/owner/repo"
        dest: "$HOME/.path/to/dest"
  
  debian:
    apt:
      - package1
      - package2
    apt_repository:
      - name: repo-name
        key: "https://example.com/key.gpg"
        repo: "deb [arch=...] https://example.com/repo stable main"
        package: package-name
    github_release:
      - name: tool-name
        repo: owner/repo
        file: "filename_VERSION.deb"
        type: deb
    script:
      - name: tool-name
        script: "curl ... | sh"
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