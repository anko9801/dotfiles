# dotfiles

Pure Nix Home Manager ベースの dotfiles。

## セットアップ

```bash
# 1. Nix インストール
sh <(curl -L https://nixos.org/nix/install) --daemon

# 2. Flakes 有効化
mkdir -p ~/.config/nix
echo 'experimental-features = nix-command flakes' >> ~/.config/nix/nix.conf

# 3. dotfiles クローン
git clone https://github.com/anko9801/dotfiles ~/.config/home-manager

# 4. Home Manager 適用
nix run home-manager -- switch --flake ~/.config/home-manager#anko@wsl
```

macOS の場合:
```bash
nix run nix-darwin -- switch --flake ~/.config/home-manager#anko-mac
```

## 構成

```
~/dotfiles (= ~/.config/home-manager)
├── flake.nix       # Flake definition
├── home.nix        # Common configuration
├── darwin/         # macOS (nix-darwin)
├── modules/
│   ├── shell/      # zsh, starship
│   ├── tools/      # cli, git, dev, linters
│   ├── services/   # syncthing
│   └── platforms/  # wsl, darwin, linux
├── configs/        # Raw config files (nvim, vim, claude)
└── overlays/
```

## コマンド

```bash
# 設定を更新
home-manager switch --flake ~/.config/home-manager

# macOS
darwin-rebuild switch --flake ~/.config/home-manager

# flake 更新
nix flake update
```

## コンセプト

- **Pure Nix** - 全て Nix で宣言的に管理
- **再現可能** - Flakes でロックされた依存関係
- **マルチプラットフォーム** - macOS, Linux, WSL
- **1Password** - SSH/GPG 鍵管理

## Tools

**Shell**: zsh + starship + fzf + zoxide + atuin

**Editor**: Neovim + lazy.nvim, Vim

**Git**: delta, gitui, ghq, gibo, lazygit, gitleaks

**Modern CLI**: bat, eza, ripgrep, fd, dust, bottom, procs, sd

**Dev**: Node.js, Python, Go, Rust, Ruby

**macOS**: yabai + skhd, Homebrew (via nix-darwin)
