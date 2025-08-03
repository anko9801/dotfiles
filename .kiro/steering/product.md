# Product Overview

## What is this Dotfiles Project?

A comprehensive development environment automation toolkit that goes beyond simple dotfile management to provide complete, reproducible system configurations across different operating systems and shells.

## Core Features

- **One-Command Environment Setup**: Single curl command installation for immediate productivity
- **Incremental Installation**: Add new tools without disrupting existing configurations
- **Cross-Platform Support**: Works seamlessly on macOS and various Linux distributions
- **Multi-Shell Compatibility**: Supports Zsh (default), Bash, and Fish shells
- **Interactive Component Selection**: Choose exactly which tools and configurations to install
- **Idempotent Operations**: Safe to run multiple times without breaking existing setups
- **Version Management**: Integrated ASDF support for consistent language runtime versions

## Target Use Cases

- **New Machine Setup**: Quickly bootstrap a complete development environment on fresh systems
- **Environment Synchronization**: Keep multiple machines with consistent configurations
- **Team Onboarding**: Standardize development environments across team members
- **Disaster Recovery**: Rapidly restore a working environment after system issues
- **Configuration Experimentation**: Try new tools without permanently affecting the system

## Key Value Proposition

This project uniquely combines:

1. **Simplicity**: No need to understand the implementation details - just run and select what you need
2. **Flexibility**: Mix and match components based on individual preferences
3. **Safety**: Non-destructive installation that respects existing configurations
4. **Maintainability**: Clear separation between logic (bash), interface (make), and configuration (ansible)
5. **Japanese Documentation**: Accessible documentation for Japanese-speaking developers

The philosophy "パパッと楽に理想の環境を手に入れるやつ" (quickly and easily get your ideal environment) drives every design decision, making this more than just dotfiles - it's a complete environment management solution.