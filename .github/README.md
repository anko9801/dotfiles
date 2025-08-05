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

**新しいマシンでも `yadm bootstrap` 一発でいつもの環境を再現したい。**

具体的には：
- **1コマンドで完結** - 複雑な手順や事前準備は不要
- **環境を自動判別** - OS（macOS/Linux/WSL/Windows）やコンテキスト（work/personal）に応じた設定
- **秘密情報の安全管理** - SSH鍵やAPIキーは1Passwordで管理、ローカルには置かない
- **クリーンな構成** - XDG Base Directory準拠で`.config/`以下に整理
- **安全な実行** - 何度実行しても既存の設定を壊さない（冪等性）

### なぜyadm？

dotfiles管理の主要な3つのアプローチ：

1. **シンボリックリンク方式**（GNU Stowなど）
   - 設定ファイルを一箇所にまとめてリンクを張る方法
   - Windowsでは権限やパスの問題でトラブルが多発

2. **ファイルコピー方式**（chezmoiなど）
   - テンプレート機能が充実
   - 実際のファイルとテンプレートの二重管理になってしまう

3. **Bare Git方式**
   - ホームディレクトリ自体をGitリポジトリとして扱うシンプルな方法
   - 余計な仕組みが不要で管理が楽
   - 素のGitだと既存ファイルの上書きや、誤って大量のファイルを追跡するリスクあり

**yadm**はBare Gitのシンプルさを保ちながら、既存ファイルの保護やテンプレート機能、環境別の設定切り替えなど、dotfiles管理に必要な機能を追加したツールです。Gitの知識があればすぐに使えて、かつ安全に運用できるのが最大の魅力です。

### こだわりポイント

- **1Passwordで認証管理** - SSH鍵とかローカルに置かない
- **モダンなCLIツール** - `ls`→`eza`、`cat`→`bat`、`sed`→`sd` など使いやすいやつに置き換え
- **賢い履歴検索** - atuinとmcflyでコマンド履歴を便利に

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
