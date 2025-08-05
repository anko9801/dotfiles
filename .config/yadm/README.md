# yadm Configuration Directory

This directory contains yadm-specific configuration files and scripts for managing dotfiles.

## Files

### `bootstrap`
Main setup script that runs after `yadm clone`. It orchestrates the entire dotfiles setup process:
- Sets up XDG directories
- Validates yadm installation
- Runs the OS/class-specific install script
- Executes post-install tasks

### `install##template`
Template-based installer that adapts to different operating systems and machine classes:
- Uses yadm's template engine to generate OS-specific configurations
- Supports: macOS, Linux (Ubuntu/Debian/Arch), WSL, Windows (Git Bash)
- Installs packages, configures tools, and sets up development environment

Template variables:
- `yadm.os`: Operating system (Darwin, Linux, Windows)
- `yadm.class`: Machine class (personal, work, server)
- `yadm.hostname`: Machine hostname
- `yadm.user`: Current username

### `hooks/`
yadm hooks for various git operations:
- `pre_commit`: Runs before commits (currently uses global git hooks)
- `post_checkout`: Could be used for post-clone tasks
- `post_merge`: Could be used for post-pull tasks

## Usage

### Manual Bootstrap
```bash
yadm bootstrap
```

### Set Machine Class
```bash
yadm config local.class personal  # or work, server
```

### Template Testing
```bash
# Generate template output without executing
yadm alt
```

### Adding New OS Support
1. Add new OS detection in `install##template`
2. Implement package manager setup
3. Add OS-specific package installations
4. Test with: `yadm bootstrap`

## Template Syntax

yadm uses a simple template syntax:
```bash
{% if yadm.os == "Darwin" %}
    # macOS specific code
{% endif %}

{% if yadm.class == "work" %}
    # Work machine specific code
{% endif %}
```

Note: yadm doesn't support `elif`, use separate `if` blocks instead.