# Technology Stack

## Architecture

**Type**: YADM-based unified dotfiles management system
- **Version Control**: YADM (Yet Another Dotfiles Manager) - Git-based dotfile management
- **Bootstrap Layer**: Automated setup via `.config/yadm/bootstrap`
- **Configuration Management**: Ansible for idempotent system state
- **Interface Layer**: Makefile for common yadm operations

## Core Technologies

### YADM (Yet Another Dotfiles Manager)
- **Purpose**: Primary dotfiles management and version control
- **Features**:
  - Git-based tracking directly in home directory
  - Automatic bootstrap execution
  - Alternate files for OS/host-specific configs
  - Built-in encryption support
  
### Shell Scripting (Bash)
- **Purpose**: Bootstrap logic, OS detection, automation
- **Key Scripts**:
  - `.config/yadm/bootstrap`: Main bootstrap script (auto-executed)
  - `.config/yadm/scripts/menu.sh`: TUI menu system
  - `install.sh`: YADM installer for new systems

### Bootstrap Scripts
- **Purpose**: OS-specific package installation and setup
- **Location**: `.config/yadm/bootstrap*`
- **Files**:
  - `bootstrap`: Main dispatcher
  - `bootstrap##os.Darwin`: macOS setup
  - `bootstrap##distro.Ubuntu`: Ubuntu/Debian setup
  - `bootstrap##distro.Arch`: Arch Linux setup
  - `bootstrap-common`: Shared functions


## Development Environment

### Supported Operating Systems
- **macOS**: Full support with Homebrew integration
- **Linux**: Ubuntu, Debian, Fedora, CentOS, Arch Linux
- **Package Managers**: apt, yum, pacman, brew

### Shell Environments
- **Zsh** (default): With Zinit plugin manager
- **Bash**: Basic configuration support
- **Fish**: Alternative shell option

### Version Management
- **ASDF**: Universal version manager for:
  - Node.js
  - Python
  - Ruby
  - Go
  - Rust
  - Perl

### Development Tools
- **Editors**: Vim (with Dein.vim), Neovim
- **Terminal**: tmux configuration included
- **Modern CLI Tools**: bat, exa, ripgrep, fd, etc.
- **CTF Tools**: Security and penetration testing utilities

## Common Commands

```bash
# Initial installation (one-time)
curl -fsSL https://raw.githubusercontent.com/anko9801/dotfiles/master/install.sh | bash
# or manually:
yadm clone https://github.com/anko9801/dotfiles

# Daily usage
make status      # Check status
make update      # Pull latest and run bootstrap
make add         # Stage changes
make commit      # Commit changes
make push        # Push to remote

# Advanced operations
yadm bootstrap   # Run bootstrap manually
yadm encrypt     # Encrypt sensitive files
yadm decrypt     # Decrypt archive
yadm alt         # Process alternate files

# Change default shell
chsh -s /bin/zsh     # Switch to Zsh
chsh -s /usr/bin/bash # Switch to Bash
chsh -s /usr/bin/fish # Switch to Fish
```

## Environment Variables

No specific environment variables are required for installation. The scripts automatically detect:
- Operating system type
- Available package managers
- Existing tool installations
- User home directory

## Port Configuration

This project does not run any services requiring port configuration. All tools are command-line utilities that don't bind to network ports.

## Dependencies

### Minimal Requirements
- Bash shell (for installation)
- curl or wget (for remote installation)
- sudo access (for system package installation)

### Auto-Installed
- Ansible (if not present)
- Git (if not present)
- Python (for Ansible)

All other dependencies are managed through the installation process based on user selections.