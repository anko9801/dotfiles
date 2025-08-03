# Project Structure

## Root Directory Organization

```
$HOME/ (Repository root = Home directory)
├── .config/           # XDG configuration directory
│   ├── git/          # Git configuration
│   ├── vim/          # Vim configuration
│   ├── tmux/         # tmux configuration
│   ├── zsh/          # Zsh configuration
│   ├── shell/        # Common shell configs
│   └── yadm/         # YADM-specific files
├── .local/           # XDG data directory
│   └── share/        # Application data
├── .zshenv           # Minimal (XDG setup only)
├── .gitignore        # Git ignore rules
├── .yadmignore       # YADM ignore rules
├── .github/          # GitHub specific files
│   └── README.md     # Project documentation
└── .kiro/            # Kiro configuration
```

## Subdirectory Structures

### .config/yadm/ - YADM Configuration
```
.config/yadm/
├── bootstrap          # Auto-executed after clone/pull
├── encrypt            # List of files to encrypt
├── ansible/           # Ansible playbooks and tasks
│   ├── playbook.yml   # Main entry point
│   ├── tasks.yml      # Core task definitions
│   ├── packages.yml   # System packages
│   ├── asdf.yml       # Version manager
│   ├── brew.yml       # Homebrew packages
│   ├── rust.yml       # Rust toolchain
│   ├── satysfi.yml    # SATySFi setup
│   └── vim.yml        # Editor config
└── scripts/           # Utility scripts
    ├── menu.sh        # Interactive TUI menu
    └── select_menu.sh # Menu helpers
```

## Code Organization Patterns

### Separation of Concerns
1. **Version Control** (YADM): Git-based dotfile management
2. **Bootstrap Layer** (.config/yadm/bootstrap): Orchestration and setup
3. **Configuration Management** (.config/yadm/ansible/): System state management
4. **Interface Layer** (Makefile): Convenient command aliases

### Task Organization
- Each Ansible file focuses on a specific domain (packages, languages, tools)
- Tasks are tagged for selective execution
- No complex role hierarchy - flat structure for simplicity

### Script Patterns
- Bash scripts use functions for modularity
- Interactive scripts separate UI from logic
- OS detection and branching handled in scripts, not Ansible

## File Naming Conventions

### Configuration Files
- Standard dotfile names (`.vimrc`, `.zshrc`, etc.)
- No prefixes or special naming - direct mapping to home directory

### Ansible Files
- `*.yml` extension for all playbooks
- Descriptive names matching the tool/purpose (vim.yml, brew.yml)
- Main entry point clearly named `playbook.yml`

### Scripts
- `*.sh` extension for shell scripts
- Verb-based naming for action scripts (setup.sh)
- Noun-based naming for utility modules (menu.sh)

## Import Organization

### Ansible Includes
```yaml
# In playbook.yml
- import_tasks: tasks.yml
  tags: always

# Conditional imports based on user selection
- import_tasks: asdf.yml
  when: install_asdf
  tags: asdf
```

### Shell Script Sourcing
- Scripts are self-contained - no complex sourcing patterns
- Menu system uses function-based composition

## Key Architectural Principles

### 1. YADM-First Design
- All dotfile management through YADM
- Direct file placement in home directory
- Git operations via YADM commands

### 2. Automated Bootstrap
- Single entry point: `yadm clone`
- Auto-execution of bootstrap script
- Self-contained setup process

### 3. Idempotency
- YADM handles file management
- Ansible ensures system state
- Safe to run multiple times

### 4. Platform Flexibility
- OS detection in bootstrap
- YADM alternates for OS-specific configs
- Conditional Ansible tasks

### 5. Security Built-in
- YADM encryption for sensitive files
- No plaintext secrets in repo
- Secure key management

### 6. User Experience
- Interactive installation menu
- Clear progress feedback
- Minimal manual steps

This architecture leverages YADM's strengths while maintaining the flexibility and power of Ansible for system configuration.