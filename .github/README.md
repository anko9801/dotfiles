# dotfiles

Nix + Home Manager で管理する個人設定。macOS / Linux / WSL / Windows 対応。

## セットアップ (1コマンド)

**Unix (macOS / Linux / WSL):**
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
│   ├── shell/                # zsh, starship, bash
│   ├── tools/                # CLI, dev tools, neovim (nixvim)
│   ├── services/             # syncthing
│   └── platforms/            # wsl, linux, darwin, server
├── darwin/                   # macOS 専用 (nix-darwin, homebrew)
├── windows/                  # Windows 専用 (winget packages)
└── configs/                  # 静的設定ファイル
```

## プラットフォーム

| 環境 | 適用コマンド |
|------|-------------|
| macOS | `darwin-rebuild switch --flake .#anko-mac` |
| Linux | `home-manager switch --flake .#anko@linux` |
| WSL | `home-manager switch --flake .#anko@wsl` |
| Server | `home-manager switch --flake .#anko@server` |
| Windows | `Update-Dotfiles` (PowerShell) |

## 主要ツール

| カテゴリ | ツール |
|----------|--------|
| シェル | zsh + starship + zsh-abbr + fzf-tab + atuin |
| エディタ | Neovim (nixvim) + VSCode |
| ターミナル | zellij (自動起動) |
| Git | lazygit + ghq + gh + delta + gitleaks |
| 検索 | ripgrep + fd + fzf |
| ファイル | eza + bat + dust + procs |
| ランタイム | mise (Node, Python, Go, Rust, Ruby) |

## キーバインド

| キー | 動作 |
|------|------|
| `Ctrl+a` | fzf で abbr 選択 |
| `Ctrl+r` | atuin 履歴検索 |
| `Ctrl+g` | zellij UI 切替 |

## コマンド

```bash
# 更新
cd ~/dotfiles && git pull
home-manager switch --flake .#anko@wsl  # or darwin-rebuild for macOS

# flake 更新
nix flake update

# lint
nix fmt
nix develop -c statix check .
nix develop -c deadnix .
```

## コンセプト

- **宣言的** - 全て Nix / winget で管理
- **再現可能** - Flakes でロック
- **クロスプラットフォーム** - 1コマンドでセットアップ
- **1Password** - SSH/GPG 鍵管理
