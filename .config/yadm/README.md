# YADM Bootstrap System

## Overview

The bootstrap system has been refactored for better modularity, maintainability, and user experience.

## Structure

```
.config/yadm/
├── bootstrap              # Main entry point (unified for all OS)
├── bootstrap-common       # Shared functions and utilities
├── bootstrap-modules      # Modular installation functions
├── bootstrap-packages     # Package manager abstraction
├── bootstrap-doctor       # Validation and troubleshooting tool
├── packages.toml          # Package configuration
└── bootstrap##os.*        # Legacy OS-specific scripts (deprecated)
```

## Key Features

### 1. Unified Bootstrap
- Single entry point for all operating systems
- Interactive configuration menu
- Progress tracking
- Comprehensive logging to `~/.config/yadm/bootstrap.log`

### 2. Package Configuration
- Centralized package definitions in `packages.toml`
- Categories: base, shell, modern-cli, development, security, etc.
- Support for optional packages
- OS-specific overrides

### 3. Error Handling
- Internet connectivity check
- Retry mechanism for network operations
- Rollback on failure
- Detailed error logging

### 4. Package Manager Abstraction
- Unified interface for brew, pacman, apt, dnf, zypper
- Automatic detection
- Fallback for manual installations

### 5. Bootstrap Doctor
- Validates bootstrap system health
- Checks for missing dependencies
- Fixes common issues
- Provides actionable recommendations

## Usage

### Running Bootstrap

```bash
yadm bootstrap
```

The bootstrap will:
1. Detect your OS and package manager
2. Show configuration options
3. Install packages based on your selections
4. Configure development environment
5. Show installation summary

### Configuration Options

- **Install optional packages**: Additional utilities and tools
- **Install programming languages**: Node.js, Python, Ruby, Go, Rust
- **Setup system ZDOTDIR**: Configure Zsh without ~/.zshenv
- **Install GUI apps** (macOS): VS Code, iTerm2, etc.
- **Configure macOS settings**: System preferences

### Checking System Health

```bash
~/.config/yadm/bootstrap-doctor
```

This will check:
- Bootstrap file integrity
- File permissions
- Package manager availability
- Installed tools
- Common configuration issues

## Customization

### Adding Packages

Edit `.config/yadm/packages.toml`:

```toml
[category-name]
packages = [
    "package1",
    "package2",
    { name = "optional-package", optional = true },
    { name = "os-specific", macos = "brew-name", linux = "apt-name" },
]
```

### Adding Installation Steps

Edit `.config/yadm/bootstrap-modules` to add new installation functions:

```bash
install_my_tools() {
    info "Installing my custom tools..."
    # Installation logic here
}
```

Then call it from the main bootstrap sequence.

## Migration from Old Bootstrap

The old OS-specific bootstrap files (`bootstrap##os.Darwin`, etc.) are now deprecated but remain for compatibility. They simply redirect to the new unified bootstrap.

## Troubleshooting

1. **Bootstrap fails**: Check `~/.config/yadm/bootstrap.log`
2. **Package not found**: Update package manager first
3. **Permission denied**: Run `bootstrap-doctor` to fix permissions
4. **Missing ZDOTDIR**: Bootstrap will offer to set it up

## Environment Variables

- `BOOTSTRAP_LOG`: Path to log file (default: `~/.config/yadm/bootstrap.log`)
- `INSTALL_OPTIONAL`: Install optional packages (y/n)
- `INSTALL_LANGUAGES`: Install programming languages (y/n)
- `SETUP_SYSTEM_ZDOTDIR`: Configure system-wide ZDOTDIR (y/n)
- `INSTALL_CASKS`: Install macOS GUI apps (y/n)
- `CONFIGURE_MACOS`: Apply macOS system settings (y/n)