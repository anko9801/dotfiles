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

```
dotfiles/
├── flake.nix              Entry point (inputs, outputs, apps)
├── config.nix             Users, hosts, module lists
├── docs/
│   └── tool-selection.md  Tool decisions and rationale
├── system/
│   ├── hosts.nix          Builds homeConfigurations from config.nix
│   ├── common.nix         Platform detection, shared defaults
│   └── windows/
│       ├── setup.sh       Windows deployment (from WSL)
│       └── winget-packages.json
├── theme/
│   └── default.nix        Stylix: colors, fonts, cursor
├── shell/
│   ├── bash.nix           Minimal bash (coreModule)
│   └── starship.nix       Prompt (baseModule)
├── tools/
│   └── git.nix            Git with identity wiring
└── editor/
    └── vim.nix            Vim (baseModule)
```

## Theming (Stylix)

[Stylix](https://github.com/danth/stylix) auto-applies a consistent color scheme, fonts, and cursor across all supported tools (terminal, editor, prompt, etc.).

The default theme is **Catppuccin Mocha**. To change it, edit `theme/default.nix`:

```nix
# Pick any scheme from base16-schemes
base16Scheme = "${pkgs.base16-schemes}/share/themes/tokyo-night-dark.yaml";
```

Available schemes: `ls $(nix build nixpkgs#base16-schemes --print-out-paths)/share/themes/`

## Windows Support

Windows configuration is built on Linux (WSL) and deployed to the Windows side.

### Setup

1. Uncomment the `windows` host in `config.nix`:

```nix
hosts = {
  default = { system = "x86_64-linux"; };
  windows = {
    system = "x86_64-linux";
    os = "windows";
  };
};
```

2. Edit `system/windows/winget-packages.json` to add your Windows packages.

3. Run from WSL:

```bash
nix run .#windows
```

This will:
- Build the `windows` Home Manager configuration
- Copy generated config files (e.g. `.gitconfig`) to your Windows home
- Install packages via `winget import`

### Platform detection in modules

```nix
{ config, lib, ... }:
{
  # Windows-specific config
  programs.git.extraConfig = lib.mkIf (config.platform.os == "windows") {
    core.autocrlf = true;
  };

  # WSL-specific config
  home.sessionVariables = lib.mkIf (config.platform.environment == "wsl") {
    BROWSER = "wslview";
  };
}
```

Available options:
- `config.platform.os` — `"linux"` | `"darwin"` | `"windows"`
- `config.platform.environment` — `"native"` | `"wsl"` | `"ci"`

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
  ./theme/default.nix
  ./shell/starship.nix
  ./tools/git.nix
  ./tools/tmux.nix     # <- add here
  ./editor/vim.nix
];
```

3. Apply: `nix run .#switch`

## Expanding

The template is designed to grow into a full-featured setup. Add directories as needed:

```
terminal/    Ghostty, WezTerm, Zellij, tmux
dev/         Rust, Go, Python, Node, mise
security/    1Password, SSH, GPG
ai/          Claude Code, Aider
desktop/     Wayland, IME
```

For a complete reference implementation, see [anko9801/dotfiles](https://github.com/anko9801/dotfiles).

## Multiple Hosts

```nix
hosts = {
  default = { system = "x86_64-linux"; };
  windows = { system = "x86_64-linux"; os = "windows"; };
  mac     = { system = "aarch64-darwin"; };
  server  = {
    system = "x86_64-linux";
    modules = [];  # server-specific extras
  };
};

defaultHosts = {
  linux = "default";
  wsl = "default";
  darwin = "mac";
};
```

Apply a specific host: `nix run .#switch -- server`

## CI

GitHub Actions workflow (`.github/workflows/check.yml`) builds your configuration on every push/PR. Uses [DeterminateSystems/nix-installer-action](https://github.com/DeterminateSystems/nix-installer-action) and [nix-community/cache-nix-action](https://github.com/nix-community/cache-nix-action).

`renovate.json` auto-updates `flake.lock` weekly via [Renovate](https://docs.renovatebot.com/).

## LLM Integration

This template is designed for LLM-assisted development:

- **`AGENTS.md`** — Instructions for LLM agents (architecture, rules, patterns)
- **`docs/tool-selection.md`** — Document your tool decisions so LLMs can make context-aware suggestions
- **Declarative config** — LLMs can read the entire environment and propose improvements
