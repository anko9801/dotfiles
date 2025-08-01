# dotfiles

パパッと楽に理想の環境を手に入れるやつ

chezmoi ベースのモダンなdotfiles管理で、OS差分を自動吸収。

## 特徴

- 🚀 **ワンコマンド**: `chezmoi init --apply` だけで完全な環境構築
- 📁 **XDG準拠**: 設定ファイルは`.config/`に整理
- 🎯 **OS自動判定**: macOS/Linux/アーキテクチャを自動検出
- 🔐 **暗号化対応**: 機密ファイルの安全な管理
- 🛡️ **ホワイトリスト方式**: 必要なファイルのみを厳選管理
- 🖥️ **高度なテンプレート**: Go template による強力な条件分岐
- 🌍 **マルチプラットフォーム**: macOS (Intel/Apple Silicon), Linux (Ubuntu, Debian, Arch)

## インストール

### 新規環境での一括セットアップ

```bash
# macOS
brew install chezmoi
chezmoi init --apply https://github.com/anko9801/dotfiles.git

# Ubuntu/Debian
sudo snap install chezmoi --classic
chezmoi init --apply https://github.com/anko9801/dotfiles.git

# Arch Linux
sudo pacman -S chezmoi
chezmoi init --apply https://github.com/anko9801/dotfiles.git
```

### 手動セットアップ

```bash
# 1. chezmoi初期化
chezmoi init https://github.com/anko9801/dotfiles.git

# 2. 設定確認（推奨）
chezmoi diff

# 3. 適用
chezmoi apply
```

## 構成

```
$HOME/
├── .config/           # 設定ファイル (XDG_CONFIG_HOME)
│   ├── git/          # Git設定
│   ├── vim/          # Vim設定とプラグイン定義
│   ├── tmux/         # tmux設定
│   ├── zsh/          # Zsh設定
│   ├── shell/        # OS別シェル設定（テンプレート化）
│   ├── atuin/        # シェル履歴管理
│   ├── starship/     # プロンプト設定
│   └── mise/         # バージョン管理設定
├── .local/           # アプリケーションデータ (XDG_DATA_HOME)
├── .zshenv           # XDG環境変数の設定
└── .gitconfig        # Git個人設定（テンプレート生成）
```

## 含まれるツール

- **Base**: git, curl, wget, tmux, tree, jq
- **Modern CLI**: bat, eza, ripgrep, fd, fzf, gh, atuin, zoxide, starship, gomi
- **Shell**: zsh (zinit)
- **Editor**: vim (dein.vim), neovim
- **Version Manager**: mise (faster asdf alternative)
- **Languages**: Node.js, Python, Ruby, Go, Rust
- **macOS**: yabai (window manager), skhd, Raycast, Warp
- **Security**: git-secrets, pre-commit hooks
- **AI Tools**: aicommits, GitHub Copilot CLI

## 使い方

### 日常的な操作

```bash
# 設定ファイルの編集
chezmoi edit ~/.zshenv
chezmoi edit ~/.config/git/config

# 変更の確認
chezmoi diff

# 変更の適用
chezmoi apply

# 状態確認
chezmoi status

# 管理対象ファイル一覧
chezmoi managed
```

### 設定の更新・同期

```bash
# リモートから最新版を取得
chezmoi update

# 手動でプル・適用
chezmoi git pull
chezmoi apply

# 変更をコミット・プッシュ
chezmoi cd
git add -A
git commit -m "Update configuration"
git push
```

### 新しいファイルの追加

```bash
# ファイルをchezmoiに追加
chezmoi add ~/.new-config-file

# テンプレートとして追加（OS差分が必要な場合）
chezmoi add --template ~/.config/app/config

# 編集
chezmoi edit ~/.config/app/config
```

## テンプレート機能

### OS固有の設定

```bash
# .config/shell/env.tmpl
{{- if eq .chezmoi.os "darwin" }}
# macOS specific
export HOMEBREW_PREFIX="/opt/homebrew"
{{- else if eq .chezmoi.os "linux" }}
# Linux specific  
export HOMEBREW_PREFIX="/home/linuxbrew/.linuxbrew"
{{- end }}
```

### アーキテクチャ検出

```bash
{{- if and (eq .chezmoi.os "darwin") (eq .chezmoi.arch "arm64") }}
# Apple Silicon specific
export HOMEBREW_PREFIX="/opt/homebrew"
{{- else if and (eq .chezmoi.os "darwin") (eq .chezmoi.arch "amd64") }}
# Intel Mac specific
export HOMEBREW_PREFIX="/usr/local"
{{- end }}
```

### ユーザー変数

```bash
# .gitconfig.tmpl
[user]
  name = {{ .name }}
  email = {{ .email }}
```

## カスタマイズ

### 個人設定の変更

初回セットアップ時に名前とメールアドレスを入力するか、後から変更：

```bash
chezmoi edit-config
# data.name と data.email を編集
```

### 新しいツールの追加

Bootstrap スクリプトに追加（OS別）：
- **macOS**: `.config/yadm/bootstrap##os.Darwin`（既存から移行）
- **Linux**: 各ディストリビューション用bootstrap

### パッケージ管理

```bash
# mise での言語バージョン管理
chezmoi edit ~/.config/mise/config.toml

# Homebrew パッケージ
# Bootstrap スクリプトに直接記述
```

## セキュリティ

**多層防御**でセキュリティを強化：
- 🛡️ **ホワイトリスト方式**: 必要なファイルのみを厳選管理
- 🔐 **SSH署名**: コミットの真正性を暗号学的に保証
- 🚫 **git-secrets**: シークレット情報の誤コミット防止
- 🔍 **pre-commit hooks**: コミット前の自動セキュリティチェック
- 🎯 **Fine-grained PAT**: 最小権限の原則でAPIアクセス制御
- 📊 **テンプレート化**: 機密情報の分離管理

### 手動設定が必要な項目

1. **GitHub noreply email**: https://github.com/settings/emails
2. **2FA確認**: https://github.com/settings/security
3. **SSH署名キー登録**: GitHub Settings > SSH and GPG keys > "Signing Key"
4. **aicommits API key**: `aicommits config set OPENAI_KEY your_key`

## AI統合

**モダンなAI開発ツール**を活用：
- 🤖 **aicommits**: AIによる自動コミットメッセージ生成
- 🚀 **GitHub Copilot CLI**: ターミナルでのAI支援

```bash
# AI コミットメッセージ生成
git add . && git ac

# GitHub Copilot CLI
gh copilot suggest "find large files"
gh copilot explain "docker run -it ubuntu"
```

## 移行ガイド

### yadm から chezmoi への移行

既存のyadmユーザー向け：

```bash
# 1. 既存yadm設定のバックアップ
yadm status
yadm commit -am "Backup before chezmoi migration"

# 2. chezmoi初期化
chezmoi init --apply https://github.com/anko9801/dotfiles.git

# 3. 設定確認・調整
chezmoi diff
chezmoi apply
```

### 主な違い

| 機能 | yadm | chezmoi |
|------|------|---------|
| OS差分 | `##os.Darwin` | `{{- if eq .chezmoi.os "darwin" }}` |
| テンプレート | 限定的 | Go template（高機能） |
| ファイル管理 | 直接管理 | `dot_` prefix変換 |
| 複雑な条件 | 困難 | 複合条件サポート |
| アーキテクチャ | 未対応 | 自動検出 |

## トラブルシューティング

### よくある問題

```bash
# テンプレートエラー
chezmoi doctor

# 設定ファイルの再生成  
chezmoi init

# 強制適用（注意）
chezmoi apply --force

# 差分表示
chezmoi diff --format=unified
```

### ログとデバッグ

```bash
# 詳細ログ
chezmoi --verbose apply

# ドライラン
chezmoi apply --dry-run

# 特定ファイルのみ処理
chezmoi apply ~/.zshenv
```

## 参考資料

- [chezmoi公式ドキュメント](https://www.chezmoi.io/)
- [Go templateリファレンス](https://pkg.go.dev/text/template)
- [XDG Base Directory Specification](https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html)

---

パパッと楽に理想の環境を手に入れよう！ 🚀

**Previous version**: yadm-backup ブランチに保存済み