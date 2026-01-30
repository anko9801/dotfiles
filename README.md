# dotfiles

Nix + Home Manager で管理する個人設定ファイル。macOS / Linux / WSL / Windows 対応。

## セットアップ

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

| 環境 | 設定適用 | 備考 |
|------|----------|------|
| macOS | `darwin-rebuild switch --flake .#anko-mac` | nix-darwin + home-manager |
| Linux | `home-manager switch --flake .#anko@linux` | Ghostty 対応 |
| WSL | `home-manager switch --flake .#anko@wsl` | Windows ssh.exe 連携 |
| Server | `home-manager switch --flake .#anko@server` | 最小構成 |
| Windows | `Update-Dotfiles` | winget でパッケージ管理 |

## 主要ツール

- **シェル**: zsh + starship + zsh-abbr + fzf-tab
- **エディタ**: Neovim (nixvim) + VSCode
- **ターミナル**: zellij (自動起動、Ctrl+g で UI 切替)
- **Git**: lazygit + ghq + gh
- **検索**: ripgrep + fd + fzf
- **その他**: eza, bat, dust, procs, bottom

## キーバインド

| キー | 動作 |
|------|------|
| `Ctrl+a` | fzf で abbr 選択 |
| `Ctrl+r` | atuin 履歴検索 |
| `Ctrl+g` | zellij UI 切替 |

## 更新

```bash
# Unix
cd ~/dotfiles && git pull && home-manager switch --flake .#anko@wsl

# Windows (PowerShell)
Update-Dotfiles
```
