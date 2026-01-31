# dotfiles

Nix + Home Manager で管理する個人設定。macOS / Linux / WSL / Windows 対応。

## セットアップ (1コマンド)

**macOS / Linux / WSL:**
```bash
curl -fsSL https://raw.githubusercontent.com/anko9801/dotfiles/master/setup | sh
```

**Windows (PowerShell 管理者):**
```powershell
iwr https://raw.githubusercontent.com/anko9801/dotfiles/master/setup | iex
```

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
│   └── theme.nix             # Stylix テーマ
├── darwin/                   # macOS 専用 (nix-darwin, homebrew)
└── windows/                  # Windows 専用 (winget, wsl.conf)
```

## コマンド

```bash
# 適用
darwin-rebuild switch --flake .#anko-mac    # macOS
home-manager switch --flake .#anko@linux    # Linux
home-manager switch --flake .#anko@wsl      # WSL
home-manager switch --flake .#anko@server   # Server
Update-Dotfiles                              # Windows (setup後に使える)

# flake 更新
nix flake update

# lint
nix fmt
nix develop -c statix check .
nix develop -c deadnix .
```

## キーバインド

| キー | 動作 |
|------|------|
| `Ctrl+a` | fzf で abbr 選択 |
| `Ctrl+r` | atuin 履歴検索 |
| `Ctrl+g` | zellij UI 切替 |

## コンセプト

- **宣言的** - Nix / winget で管理
- **再現可能** - Flakes でロック
- **クロスプラットフォーム** - 1コマンドでセットアップ
- **1Password** - SSH/GPG 鍵 + API キー管理

## 1Password 連携

```bash
# API キー一括ロード
load-secrets              # Personal vault から
load-secrets Work         # 指定 vault から

# 個別取得
opsecret "OpenAI/credential"
export MY_KEY=$(opsecret "Item/field")
```

| カテゴリ | ツール |
|----------|--------|
| シェル | zsh + starship + zsh-abbr + fzf-tab + atuin |
| エディタ | Neovim (nixvim) + VSCode |
| ターミナル | zellij (自動起動) |
| Git | lazygit + ghq + gh + delta + gitleaks |
| 検索 | ripgrep + fd + fzf |
| ファイル | eza + bat + dust + procs |
| ランタイム | mise (Node, Python, Go, Rust, Ruby) |
