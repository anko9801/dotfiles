# dotfiles

Pure Nix Home Manager ベースの dotfiles。

## セットアップ

### macOS (ワンライナー)

```bash
curl -fsSL https://raw.githubusercontent.com/anko9801/dotfiles/master/scripts/setup-darwin.sh | bash
```

### 手動セットアップ

```bash
# 1. Nix インストール (Determinate Installer)
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

# 2. dotfiles クローン
git clone https://github.com/anko9801/dotfiles ~/dotfiles

# 3. 適用
nix run home-manager -- switch --flake ~/dotfiles#<user>@wsl      # WSL
nix run home-manager -- switch --flake ~/dotfiles#<user>@linux    # Linux
sudo nix run nix-darwin -- switch --flake ~/dotfiles#<user>-mac   # macOS
```

## 構成

```
~/dotfiles
├── flake.nix       # Flake definition
├── home.nix        # Common configuration
├── darwin/         # macOS (nix-darwin)
├── modules/
│   ├── shell/      # zsh, starship
│   ├── tools/      # cli, git, dev, neovim
│   ├── services/   # syncthing
│   └── platforms/  # wsl, darwin, linux
└── configs/        # Raw config files (wsl, claude)
```

## コマンド

```bash
# 設定を更新
home-manager switch --flake ~/dotfiles#<user>@wsl       # Linux/WSL
sudo darwin-rebuild switch --flake ~/dotfiles#<user>-mac  # macOS

# flake 更新
nix flake update

# 開発シェル (nixfmt, statix, deadnix, nixd)
nix develop

# フォーマット
nix fmt
```

## コンセプト

- **Pure Nix** - 全て Nix で宣言的に管理
- **再現可能** - Flakes でロックされた依存関係
- **マルチプラットフォーム** - macOS, Linux, WSL
- **1Password** - SSH/GPG 鍵管理

## Tools

**Shell**: zsh + starship + fzf + zoxide + atuin

**Editor**: Neovim (nixvim), Vim

**Git**: delta, gitui, ghq, gibo, lazygit, gitleaks

**Modern CLI**: bat, eza, ripgrep, fd, dust, bottom, procs, sd

**Dev**: mise (Node.js, Python, Go, Rust, Ruby, etc.)

**macOS**: AeroSpace, Raycast, Homebrew (via nix-darwin)
