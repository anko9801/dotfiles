# dotfiles

Nix Home Manager ベースの dotfiles 管理。

## セットアップ

```bash
# yadm インストール
brew install yadm                # macOS
sudo apt install -y yadm         # Ubuntu/Debian

# dotfiles クローン
yadm clone https://github.com/anko9801/dotfiles

# セットアップ (Nix + Home Manager をインストール)
yadm bootstrap
```

## 構成

```
.config/
├── home-manager/    # Nix Home Manager (メイン設定)
│   ├── flake.nix    # Flake definition
│   ├── home.nix     # Common configuration
│   ├── darwin/      # macOS (nix-darwin)
│   └── modules/     # Shell, tools, platforms
├── nvim/            # Neovim configuration
├── vim/             # Vim configuration
└── yadm/            # Bootstrap script
```

## コンセプト

- **宣言的** - Nix Flakes で再現可能な環境
- **シンプル** - yadm + Home Manager の組み合わせ
- **マルチプラットフォーム** - macOS, Linux, WSL をサポート
- **セキュア** - 1Password で SSH/GPG 鍵を管理

## コマンド

```bash
# 設定を更新
home-manager switch --flake ~/.config/home-manager

# macOS の場合
darwin-rebuild switch --flake ~/.config/home-manager

# flake を更新
cd ~/.config/home-manager && nix flake update
```

## Tools

**Shell**: zsh + starship + fzf + zoxide + atuin

**Editor**: Neovim + lazy.nvim, Vim

**Git**: delta, gitui, ghq, gibo, lazygit, gitleaks

**Modern CLI**: bat, eza, ripgrep, fd, dust, bottom, procs, sd

**Dev**: Node.js, Python, Go, Rust, Ruby

**macOS**: yabai + skhd, Raycast
