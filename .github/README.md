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

新しいマシンでもコマンド一発でいつもの環境を再現したい。

- **1コマンドで完結** - 複雑な手順や事前準備は不要
- **環境を自動判別** - OS (macOS/Linux/WSL/Windows) やコンテキスト (work/personal) に応じた設定
- **シークレットの安全管理** - SSH 鍵や API キーは 1Password で管理、ローカルには置かない
- **クリーンな構成** - XDG Base Directory 準拠で`.config/`以下に整理
- **完全な環境の再現性** - 必要なツールはすべて宣言的に管理、どこでも同じ環境を構築
- **冪等性** - 何度実行しても既存の設定を壊さない

### なぜyadm？

dotfiles 管理は主に 3 つの方法があります。

1. **シンボリックリンク方式** (GNU Stow など)
   - 設定ファイルを一箇所にまとめてリンクを張る方法
   - Windowsでは権限やパスの問題でトラブルが多発

2. **ファイルコピー方式** (chezmoi など)
   - テンプレート機能が充実
   - 実際のファイルとテンプレートの二重管理になってしまう
   - 独自のコマンド体系を覚える必要があり管理が複雑

3. **Bare Git方式** (yadm など)
   - ホームディレクトリ自体をGitリポジトリとして扱うシンプルな方法
   - 余計な仕組みが不要で管理が楽
   - 素のGitだと既存ファイルの上書きや、誤って機密情報を含むファイルを追跡するリスクあり

**yadm** は Bare Git のシンプルさを保ちながら、既存ファイルの保護やテンプレート機能、環境別の設定切り替えなど、dotfiles 管理に必要な機能を追加したツールです。Git の知識があればすぐに使えて、かつ安全に運用できるのが最大の魅力です。

### こだわりポイント

- **1Passwordで認証管理** - SSH 鍵とかをローカルに置かない 詳細は [op/README.md](../.config/op/README.md) を参照してください。
- **モダンなCLIツール** - `ls`→`eza`、`cat`→`bat`、`sed`→`sd` など使いやすいやつに置き換え
- **賢い履歴検索** - atuinとmcflyでコマンド履歴を便利に

## ツール構成

**共通ツール**:
- **バージョン管理**: mise
- **シェル**: zsh + sheldon
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
