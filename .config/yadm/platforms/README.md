# Platform-specific Settings

This directory contains platform-specific configuration scripts that are executed during the bootstrap process.

## Structure

### macos.sh
macOS system settings and configurations:
- Show hidden files in Finder
- Enable fast key repeat
- Disable press-and-hold for keys
- Apply Finder changes

### wsl.sh
WSL integration and configurations:
- Disable Windows PATH pollution
- Create Windows home symlink
- Configure Git for WSL

## Usage

These scripts are automatically executed by the install script based on the detected platform. They can also be run manually:

```bash
# Run macOS settings
~/.config/yadm/platforms/macos.sh

# Run WSL settings
~/.config/yadm/platforms/wsl.sh
```

## Adding New Platforms

To add settings for a new platform:

1. Create a new script file (e.g., `linux.sh`)
2. Add platform detection logic in the script
3. Update the install script to call your new platform script

## Script Structure

Each platform script should:
- Check if it's running on the correct platform
- Skip execution if not applicable
- Use logging functions (info, success, error, warning, verbose)
- Be idempotent (safe to run multiple times)