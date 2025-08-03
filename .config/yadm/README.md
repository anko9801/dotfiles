# YADM Configuration

このリポジトリはyadmの機能をフル活用しています。

## yadm機能の活用

### 1. Templates (テンプレート)
動的な設定生成のためにテンプレートを使用：

- `.config/tmux/tmux.conf##template` - OS別のシェルパスと設定
- `.config/starship.toml##template` - マシンクラス別のプロンプト
- `.ssh/config##template` - OS別のSSHエージェントパス
- `.gitconfig##template` - 環境別のGit設定

### 2. Alternates (代替ファイル)
OS/ディストロ/ホスト名別の設定：

- `.config/shell/env##os.Darwin` - macOS用環境変数
- `.config/shell/env##os.Linux` - Linux用環境変数
- `.config/atuin/config.toml##class.work` - 仕事用マシンの設定
- `.config/atuin/config.toml##class.personal` - 個人用マシンの設定

### 3. Encryption (暗号化)
機密ファイルの暗号化（`.config/yadm/encrypt`で定義）：

- SSH秘密鍵
- GPG鍵
- 環境変数ファイル（.env）
- AWS認証情報
- その他の機密設定

### 4. Hooks (フック)
自動化されたタスク：

- `pre_commit` - コミット前のチェック（lint、フォーマット等）
- `post_alt` - テンプレート生成後の設定（権限、再読み込み）
- `post_checkout` - チェックアウト後のクリーンアップ

### 5. Classes (クラス)
マシンタイプ別の設定：

```bash
# クラスを設定
yadm config local.class work     # 仕事用マシン
yadm config local.class personal # 個人用マシン
yadm config local.class server   # サーバー
```

## 使い方

### 初期セットアップ

```bash
# yadmをインストール
brew install yadm  # macOS
# または
sudo apt install yadm  # Ubuntu

# リポジトリをクローン
yadm clone https://github.com/yourusername/dotfiles.git

# クラスを設定（オプション）
yadm config local.class personal

# 代替ファイルとテンプレートを生成
yadm alt

# Bootstrapを実行
yadm bootstrap
```

### 暗号化されたファイルの管理

```bash
# 暗号化
yadm encrypt

# 復号化
yadm decrypt

# 暗号化されたファイルのリストを表示
yadm list -a
```

### テンプレート変数のカスタマイズ

`.config/yadm/config.local`を作成して変数を設定：

```ini
yadm.class = "work"
yadm.shell = "/opt/homebrew/bin/zsh"
yadm.terminal = "wezterm"
```

# YADM Bootstrap System

## Overview

yadmの機能をフル活用したbootstrapシステムです。OS、ディストリビューション、マシンクラスに応じて自動的に適切な設定とパッケージをインストールします。

## Bootstrap Features

### 1. OS-specific Bootstrap
- `bootstrap##os.Darwin` - macOS用
- `bootstrap##os.Linux` - Linux用
- 自動的に適切なスクリプトが実行されます

### 2. Class-based Installation
マシンクラスに応じたパッケージインストール：
- **personal**: 個人用ツール（media tools, personal apps）
- **work**: 仕事用ツール（AWS, Docker, Kubernetes）
- **server**: サーバー用最小構成

### 3. Brewfile Template
macOSではBrewfileテンプレートを使用：
- クラス別のパッケージ定義
- Caskアプリの管理

### 4. Pre-bootstrap Check
`bootstrap-check`で事前設定：
- クラスの選択
- オプションの確認
- インストール内容のプレビュー

## Structure

```
.config/yadm/
├── bootstrap              # Main entry point
├── bootstrap##os.Darwin   # macOS bootstrap
├── bootstrap##os.Linux    # Linux bootstrap  
├── bootstrap-check        # Pre-bootstrap configuration
├── bootstrap-common       # Shared functions
└── config                 # yadm configuration template

.config/homebrew/
└── Brewfile##template     # macOS packages (template)
```

## Key Features

### 1. Unified Bootstrap
- Single entry point for all operating systems
- Interactive configuration menu
- Progress tracking
- Comprehensive logging to `~/.config/yadm/bootstrap.log`

### 2. Package Configuration
- Centralized package definitions in `packages.toml`
- Categories: base, shell, modern-cli, development, security, etc.
- Support for optional packages
- OS-specific overrides

### 3. Error Handling
- Internet connectivity check
- Retry mechanism for network operations
- Rollback on failure
- Detailed error logging

### 4. Package Manager Abstraction
- Unified interface for brew, pacman, apt, dnf, zypper
- Automatic detection
- Fallback for manual installations

### 5. Bootstrap Doctor
- Validates bootstrap system health
- Checks for missing dependencies
- Fixes common issues
- Provides actionable recommendations

## Usage

### Running Bootstrap

```bash
# 1. まず設定を確認
~/.config/yadm/bootstrap-check

# 2. Bootstrapを実行
yadm bootstrap
```

#### 自動実行されること：
1. OSとディストリビューションの検出
2. クラスに応じたパッケージのインストール
3. 開発環境のセットアップ
4. AIツールの設定
5. インストールサマリーの表示

### Bootstrap Classes

#### Personal Class
```bash
yadm config local.class personal
```
- 基本パッケージ + 個人用ツール
- メディアツール（ffmpeg, imagemagick）
- 個人用アプリ（Obsidian, Spotify）

#### Work Class
```bash
yadm config local.class work
```
- 基本パッケージ + 仕事用ツール
- クラウドツール（AWS CLI, Terraform）
- コンテナツール（Docker, Kubernetes）
- セキュリティツール（Vault, Consul）

#### Server Class
```bash
yadm config local.class server
```
- 最小限のパッケージセット
- サーバー管理ツール（htop, ncdu）
- GUIアプリなし

### Customization

#### macOSパッケージの追加
`.config/homebrew/Brewfile##template`を編集：

```ruby
# 基本パッケージ
brew "your-package"

# クラス別パッケージ
{% if yadm.class == "work" %}
brew "work-specific-tool"
{% endif %}
```

#### Linuxパッケージの追加
`.config/yadm/bootstrap##os.Linux`の該当セクションを編集

## Troubleshooting

1. **Bootstrapが失敗**: エラーメッセージを確認
2. **パッケージが見つからない**: パッケージマネージャーを更新
3. **Brewfileがない**: `yadm alt`を実行

## Environment Variables

- `YADM_BOOTSTRAP`: Set to 1 to run bootstrap directly (not recommended)
- `YADM_BOOTSTRAP_OPTIONAL`: Install optional packages (y/n)
- `YADM_BOOTSTRAP_MACOS_SETTINGS`: Configure macOS settings (true/false)
- `BOOTSTRAP_LOG`: Log file path (default: `~/.config/yadm/bootstrap.log`)