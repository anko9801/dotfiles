# dotfiles

Nix + Home Manager で管理する個人設定ファイル。macOS / Linux / WSL / Windows に対応。

宣言的で再現可能なクロスプラットフォーム環境を目指している。新しいマシンでも1コマンドで同じ環境が手に入る。

> [!Note]
> このリポジトリは個人用に最適化されている。フォークして自分用にカスタマイズすることをおすすめする。

## セットアップ

**macOS / Linux / WSL:**
```bash
curl -fsSL https://raw.githubusercontent.com/anko9801/dotfiles/master/setup | sh
```

**Windows (PowerShell 管理者権限):**
```powershell
iwr https://raw.githubusercontent.com/anko9801/dotfiles/master/setup | iex
```

> [!Important]
> セットアップスクリプトはインタラクティブに動作する。各ステップで確認プロンプトが表示されるので、スキップも可能。

セットアップスクリプトは以下を行う:
1. OS とアーキテクチャを検出 (Apple Silicon / Intel / ARM64)
2. Nix をインストール (Determinate Systems installer)
3. このリポジトリをクローン
4. 適切な設定を適用

## 構成

```
dotfiles/
├── flake.nix                 # Nix Flake 定義
├── home.nix                  # Home Manager 共通設定
├── setup                     # ポリグロット セットアップスクリプト
├── modules/
│   ├── shell/                # zsh, starship, bash, fish
│   ├── tools/                # CLI, dev, neovim, claude
│   ├── platforms/            # wsl, linux, darwin, server
│   └── theme.nix             # Stylix テーマ (Tokyo Night)
├── darwin/                   # macOS 専用 (nix-darwin, homebrew)
└── windows/                  # Windows 専用 (winget, wsl.conf)
```

## 適用コマンド

設定を適用するには、プラットフォームに応じたコマンドを実行する。

```bash
# macOS
darwin-rebuild switch --flake .#anko-mac

# Linux
home-manager switch --flake .#anko@linux

# WSL
home-manager switch --flake .#anko@wsl

# Server (最小構成)
home-manager switch --flake .#anko@server
```

その他のコマンド:

```bash
# flake 入力を更新
nix flake update

# フォーマット
nix fmt

# Lint
nix develop -c statix check .
nix develop -c deadnix .
```

## ZSH 設定

メインシェルは ZSH。以下のプラグインと機能を使用している。

| プラグイン | 説明 |
|------------|------|
| zsh-abbr | 略語展開 (fish 風) |
| fzf-tab | タブ補完を fzf で |
| zsh-autosuggestions | コマンド候補表示 |
| zsh-syntax-highlighting | シンタックスハイライト |
| atuin | 履歴検索 (SQLite) |

### キーバインド

| キー | 動作 |
|------|------|
| `Ctrl+a` | fzf で abbr 選択 |
| `Ctrl+r` | atuin 履歴検索 |
| `Ctrl+g` | zellij UI 切替 |
| `jk` | ESC (insert mode) |

### カスタム関数

```bash
ghq-fzf    # ghq + fzf でリポジトリ移動
mkcd       # mkdir && cd
extract    # アーカイブ展開
fcd        # fzf でディレクトリ移動
fkill      # fzf でプロセス kill
fbr        # fzf で git branch 切り替え
```

## Neovim 設定

Neovim は [nixvim](https://github.com/nix-community/nixvim) で設定している。Lua ファイルではなく Nix で宣言的に管理。

```
modules/tools/neovim/
├── default.nix      # 基本設定
├── options.nix      # エディタオプション
├── keymaps.nix      # キーバインド
├── plugins.nix      # プラグイン設定
└── lsp.nix          # LSP / フォーマッター
```

### 主要プラグイン

- **telescope.nvim** - ファジーファインダー
- **nvim-treesitter** - シンタックスハイライト
- **nvim-lspconfig** - LSP クライアント
- **nvim-cmp** - 補完
- **which-key.nvim** - キーバインドヘルプ
- **oil.nvim** - ファイルマネージャー
- **gitsigns.nvim** - Git 差分表示

> [!Note]
> Server プロファイルでは nixvim を無効化し、代わりに軽量な vim を使用する。

## Zellij 設定

ターミナルマルチプレクサは zellij を使用。シェル起動時に自動でアタッチする。

デフォルトは locked モードで、UI は非表示。`Ctrl+g` で UI を表示できる。

## 1Password 連携

SSH 鍵と API シークレットは 1Password で管理している。

### SSH エージェント

| プラットフォーム | 方式 |
|------------------|------|
| WSL | Windows の `ssh.exe` を直接使用 |
| macOS | 1Password SSH エージェントソケット |
| Linux | 1Password SSH エージェントソケット |

### API キーの読み込み

```bash
# 一括ロード
load-secrets              # Personal vault から
load-secrets Work         # 指定 vault から

# 個別取得
opsecret "OpenAI/credential"
export MY_KEY=$(opsecret "Item/field")
```

## プラットフォーム別設定

### WSL

- Windows `ssh.exe` で 1Password SSH エージェント連携
- `clip.exe` / `pbpaste` エイリアス
- `wslview` による `xdg-open` 対応
- 時刻同期 (`wsl2_fix_time`) とメモリ解放 (`wsl2_compact_memory`)

### macOS

- Homebrew で GUI アプリ管理 (casks)
- Aerospace タイリングウィンドウマネージャー
- システムデフォルト設定

### Server

- 最小構成 (nixvim 無効、vim 使用)
- 必須ツールのみ
- 高速デプロイ

### Windows

winget で宣言的にパッケージ管理。`windows/winget-packages.json` で定義。

主なパッケージ:
- 開発: Git, Docker, Go, VSCode, Zed
- ターミナル: Windows Terminal, PowerShell 7, Starship
- ユーティリティ: PowerToys, Everything, Ditto, ShareX, DevToys
- 通信: Slack, Discord, Zoom

## ツール一覧

| カテゴリ | ツール |
|----------|--------|
| シェル | zsh + starship + zsh-abbr + fzf-tab + atuin |
| エディタ | Neovim (nixvim) + VSCode + Zed |
| ターミナル | zellij (自動起動) |
| Git | lazygit + ghq + gh + delta + gitleaks |
| 検索 | ripgrep + fd + fzf |
| ファイル | eza + bat + dust + procs |
| ランタイム | mise (Node, Python, Go, Rust, Ruby) |
| 同期 | rsync over Tailscale |

## コンセプト

- **宣言的** - Nix / winget で全て管理
- **再現可能** - Flakes で依存関係をロック
- **クロスプラットフォーム** - 1コマンドでセットアップ
- **1Password** - 認証情報を一元管理

## License

MIT
