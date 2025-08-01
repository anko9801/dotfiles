# dotfiles

パパッと楽に理想の環境を手に入れるやつ

XDG Base Directory仕様に準拠したモダンなdotfiles管理。

## 特徴

- 🚀 **ワンコマンド**: `yadm clone` だけで完全な環境構築
- 📁 **XDG準拠**: 設定ファイルは`.config/`に整理
- 🎯 **OS自動判定**: yadm alternateでOS別の設定を自動適用
- 🔐 **暗号化対応**: 機密ファイルの安全な管理
- 🛡️ **ホワイトリスト方式**: 必要なファイルのみを厳選管理
- 🐚 **Zsh最適化**: zsh環境に特化した高速で直接的な設定
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
└── .zshenv           # XDG環境変数の設定（最小限）
```

## 含まれるツール

- **Base**: git, curl, wget, tmux, tree, jq
- **Modern CLI**: bat, eza, ripgrep, fd, fzf, gh, atuin, zoxide, starship, gomi
- **Shell**: zsh (zinit), .zshenv
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

## 初回セットアップ

クローン後に個人設定を行う：

```bash
# ユーザー情報を設定（重要！）
yadm config yadm.user "Your Name"
yadm config yadm.email "your.email@example.com"

# テンプレートを生成して~/.gitconfigを作成
yadm alt

# SSH署名キーをGitHubに登録
cat ~/.ssh/id_ed25519.pub
# ↑をGitHub Settings > SSH and GPG keys > "Signing Key"として追加
```

## カスタマイズ

新しいパッケージを追加する場合は、OS別のbootstrapファイルを編集：
- macOS: `.config/yadm/bootstrap##os.Darwin`
- Ubuntu: `.config/yadm/bootstrap##distro.Ubuntu`
- Arch: `.config/yadm/bootstrap##distro.Arch`

Git設定のカスタマイズは `.config/git/config` を編集。

## ファイル構成

プロジェクト関連ファイル：
- `.github/README.md` - プロジェクトドキュメント（ホーム汚染回避）
- `.pre-commit-config.yaml` - コード品質・セキュリティチェック設定

## セキュリティ

**多層防御**でセキュリティを強化：
- 🛡️ **ホワイトリスト方式**: 必要なファイルのみを厳選管理
- 🔐 **SSH署名**: コミットの真正性を暗号学的に保証
- 🚫 **git-secrets**: シークレット情報の誤コミットを防止
- 🔍 **pre-commit hooks**: コミット前の自動セキュリティチェック
- 🎯 **Fine-grained PAT**: 最小権限の原則でAPIアクセス制御

除外される機密データ：
- 個人データ (Desktop/, Documents/, etc.)
- 認証情報 (.ssh/id_*, .gitconfig, etc.)  
- 開発ディレクトリ (workspace/, projects/, etc.)

## AI統合

**モダンなAI開発ツール**を活用：
- 🤖 **aicommits**: AIによる自動コミットメッセージ生成
- 🚀 **GitHub Copilot CLI**: ターミナルでのAI支援

---

パパッと楽に理想の環境を手に入れよう！ 🚀