# Claude Code Project Guide

This project uses Claude Code for AI-assisted development. This document provides context and guidelines for effective collaboration.

## Project Overview

**Purpose**: Personal dotfiles configuration for development environment setup
**Main Technologies**: Shell scripting, YADM, Various CLI tools
**Key Features**: Cross-platform support, automated setup, modern CLI tools integration

## Development Guidelines

### Code Style
- Use shellcheck-compliant bash scripts
- Follow XDG Base Directory specification
- Keep configurations modular and well-documented
- Ensure idempotency in all setup scripts

### Testing Approach
- Test bootstrap scripts in clean environments
- Verify cross-platform compatibility (macOS, Linux, WSL)
- Check for existing files before modifications

### Important Commands
- `yadm bootstrap` - Run full setup
- `yadm alt` - Generate templates
- `czg` - Create conventional commits
- `gitui` - Interactive git interface

## Project Structure

```
.config/
├── git/          # Git configuration
├── zsh/          # Shell configuration
├── nvim/         # Neovim setup
├── tmux/         # Terminal multiplexer
├── mise/         # Tool version management
├── yadm/         # Bootstrap scripts
├── yabai/        # Window manager (macOS)
├── skhd/         # Hotkey daemon (macOS)
└── claude/       # This configuration
```

## Security Considerations

- Never store secrets in plain text
- Use 1Password for credential management
- All SSH keys should be managed via 1Password SSH agent
- Sensitive files should use YADM encryption if needed

## Common Tasks

### Adding a new tool
1. Add to appropriate package manager config (Brewfile, install script)
2. Create configuration in `.config/toolname/`
3. Update relevant documentation
4. Test installation on clean system

### Updating configurations
1. Make changes in appropriate config files
2. Test changes locally
3. Commit with conventional commit message using `czg`
4. Push to repository

## AI Assistant Guidelines

When working on this project:
- Prioritize idempotency and safety
- Always check for existing files before creating
- Follow existing patterns and conventions
- Document any significant changes
- Test commands before suggesting them