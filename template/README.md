# Nix Dotfiles

Minimal, declarative dotfiles using [Nix](https://nixos.org/) and [Home Manager](https://github.com/nix-community/home-manager).

## Quick Start

```bash
# 1. Install Nix
curl -L https://nixos.org/nix/install | sh -s -- --daemon

# 2. Initialize
mkdir ~/dotfiles && cd ~/dotfiles
nix flake init -t github:anko9801/dotfiles

# 3. Edit config.nix (replace your-username with $USER)

# 4. Apply (conflicting files are backed up as .backup)
nix run .#switch

# 5. (Optional) Deploy Windows config from WSL
#    Uncomment the `windows` host in config.nix, then:
nix run .#windows  # copies configs + runs winget import
```

## Adding Modules

1. Create a file (e.g., `tools/tmux.nix`)
2. Add it to `baseModules` in `config.nix`
3. Run `nix run .#switch`

Full reference: [anko9801/dotfiles](https://github.com/anko9801/dotfiles)
