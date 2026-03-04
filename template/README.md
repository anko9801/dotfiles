# Nix Dotfiles

Minimal, declarative dotfiles using [Nix](https://nixos.org/) and [Home Manager](https://github.com/nix-community/home-manager).

## Quick Start

### 1. Install Nix

```bash
curl -L https://nixos.org/nix/install | sh -s -- --daemon
```

### 2. Initialize from template

```bash
mkdir ~/dotfiles && cd ~/dotfiles
nix flake init -t github:anko9801/dotfiles
```

### 3. Configure

Edit `config.nix`:

```nix
users = {
  your-username = {         # must match $USER
    userName = "Your Name";
    userEmail = "you@example.com";
  };
};
```

### 4. Apply

```bash
nix run .#switch
```

This backs up any conflicting files (with `.backup` extension) and activates the configuration.

## Structure

| File | Role |
|------|------|
| `flake.nix` | Nix entry point (inputs, outputs, apps) |
| `config.nix` | Users, hosts, module lists |
| `system/hosts.nix` | Builds homeConfigurations from config.nix |
| `system/common.nix` | Platform detection, shared defaults |
| `shell/bash.nix` | Minimal bash (coreModule) |
| `shell/starship.nix` | Prompt customization (baseModule) |
| `tools/git.nix` | Git config with identity wiring |
| `editor/vim.nix` | Vim setup (baseModule) |

## Adding Modules

1. Create a file (e.g., `tools/tmux.nix`):

```nix
{ ... }:
{
  programs.tmux = {
    enable = true;
    terminal = "tmux-256color";
    escapeTime = 0;
  };
}
```

2. Add it to `baseModules` in `config.nix`:

```nix
baseModules = [
  ./shell/starship.nix
  ./tools/git.nix
  ./tools/tmux.nix     # <- add here
  ./editor/vim.nix
];
```

3. Apply: `nix run .#switch`

## Multiple Hosts

Define hosts in `config.nix` for different machines:

```nix
hosts = {
  default = { system = "x86_64-linux"; };
  mac     = { system = "aarch64-darwin"; };
  server  = {
    system = "x86_64-linux";
    modules = [];  # server-specific extras
  };
};

defaultHosts = {
  linux = "default";
  darwin = "mac";
};
```

Apply a specific host: `nix run .#switch -- server`

## Extending

- **NixOS / nix-darwin**: See [anko9801/dotfiles](https://github.com/anko9801/dotfiles) for a full example with NixOS, nix-darwin, nixvim, stylix, and more.
- **Flake inputs**: Add nixvim, stylix, etc. to `flake.nix` inputs and wire their home-manager modules through `hosts.nix`.
- **AI integration**: Add Claude Code, Aider, or other LLM tools as modules.
