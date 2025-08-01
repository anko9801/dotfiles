# dotfiles

パパッと楽に理想の環境を手に入れるやつ

XDG Base Directory仕様に準拠したモダンなdotfiles管理。

## 特徴

- 🚀 **ワンコマンド**: `yadm clone` だけで完全な環境構築
- 📁 **XDG準拠**: 設定ファイルは`.config/`に整理
- 🎯 **OS自動判定**: yadm alternateでOS別の設定を自動適用
- 🔐 **暗号化対応**: 機密ファイルの安全な管理
- 🌍 **マルチプラットフォーム**: macOS, Linux (Ubuntu, Debian, Arch)

## インストール

```bash
# macOS
brew install yadm && yadm clone https://github.com/anko9801/dotfiles

# Ubuntu/Debian
sudo apt install -y yadm && yadm clone https://github.com/anko9801/dotfiles

# Arch Linux
sudo pacman -S --noconfirm yadm && yadm clone https://github.com/anko9801/dotfiles
```

## 構成

```
$HOME/
├── .config/           # 設定ファイル (XDG_CONFIG_HOME)
│   ├── git/          # Git設定
│   ├── vim/          # Vim設定とプラグイン定義
│   ├── tmux/         # tmux設定
│   ├── zsh/          # Zsh設定
│   ├── shell/        # 共通シェル設定とエイリアス
│   └── yadm/         # yadm bootstrap と hooks
├── .local/           # アプリケーションデータ (XDG_DATA_HOME)
│   └── share/
│       └── vim/      # Vimのデータファイル
└── .zshenv           # XDG環境変数の設定（最小限）
```

## 含まれるツール

- **Base**: git, curl, wget, tmux, tree, jq
- **Modern CLI**: bat, eza, ripgrep, fd, fzf, gh, atuin, zoxide, starship, gomi
- **Shell**: zsh (zinit), fish
- **Editor**: vim (dein.vim), neovim
- **Version Manager**: mise (faster asdf alternative)
- **Languages**: Node.js, Python, Ruby, Go, Rust
- **macOS**: yabai (window manager), skhd, Raycast, Warp

## 使い方

```bash
# 状態確認
yadm status

# 更新
yadm pull && yadm bootstrap

# 設定の追加
yadm add ~/.config/newapp
yadm commit -m "Add newapp config"
yadm push
```

## カスタマイズ

新しいパッケージを追加する場合は、OS別のbootstrapファイルを編集：
- macOS: `.config/yadm/bootstrap##os.Darwin`
- Ubuntu: `.config/yadm/bootstrap##distro.Ubuntu`
- Arch: `.config/yadm/bootstrap##distro.Arch`

---

パパッと楽に理想の環境を手に入れよう！ 🚀