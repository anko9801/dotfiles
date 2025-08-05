# dotfiles

パパッと楽に理想の環境を手に入れるやつ

```bash
# インストール
brew install yadm  # macOS
sudo apt install -y yadm  # Ubuntu/Debian  
sudo pacman -S --noconfirm yadm  # Arch Linux

# セットアップ
yadm clone https://github.com/anko9801/dotfiles
yadm status && yadm diff  # 既存設定がある場合は競合確認
yadm reset --hard origin/master  # 必要に応じて既存設定を破棄
yadm bootstrap
```

## 特徴

### やりたいこと

新しいマシンでも `yadm bootstrap` 一発でいつもの環境にしたい。それだけ。

### こだわりポイント

- **yadm使用** - 普通のGitコマンドで管理できて楽
- **1Passwordで認証管理** - SSH鍵とかローカルに置かない
- **モダンなCLIツール** - `ls`→`eza`、`cat`→`bat`、`sed`→`sd` など使いやすいやつに置き換え
- **賢い履歴検索** - atuinとmcflyでコマンド履歴を便利に
- **OS/環境別の設定** - macOS/Linux/WSL、work/personalで自動切り替え

### 便利な設定

- Git設定で`push`時に自動でupstream設定（`autoSetupRemote`）
- コンフリクト解決を記憶する`rerere`
- `czg`でキレイなコミットメッセージ
- deltaで見やすいdiff表示（side-by-side）
- zsh abbreviationsで長いコマンドを短縮

### 1Password によるシークレット管理

詳細は [op/README.md](../.config/op/README.md) を参照してください。

- **SSH Agent**: 全ての SSH 秘密鍵を 1Password で一元管理
- **Git 署名**: SSH 鍵でコミットに署名（GPG 不要）
- **CLI 認証**: gh, AWS CLI などの認証情報を安全に管理
- **環境変数**: `op://` 参照で秘密情報を Git から分離
- **ゼロトラスト**: ローカルに秘密情報を一切保存しない

## ツール構成

**共通ツール**:
- **バージョン管理**: mise
- **シェル**: zsh + antidote
- **エディタ**: Vim + dpp.vim, Neovim + lazy.nvim
- **開発ツール**: git, tmux, gitleaks
- **Modern CLI**: bat, eza, ripgrep, fd, fzf, gh, starship, zoxide, atuin, mcfly, delta, duf, dust, tokei, sd
- **Python**: uv, ruff

**OS別対応**:
- **macOS**: Homebrew経由でツールインストール
- **Linux**: apt/pacman/dnf + 最新版は.debファイルから
- **WSL**: Windows連携ツール (pbcopy/pbpaste, explorer統合)
- **Windows**: winget経由でツールインストール、Git Bash環境

**クラス別構成**:
- **Personal**: メディアツール (ffmpeg, yt-dlp)、個人アプリ (Obsidian, Spotify)
- **Work**: クラウド・コンテナツール (AWS CLI, terraform, kubectl, docker)
- **Server**: 最小構成（基本ツールのみ）
