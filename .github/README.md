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

## コンセプト

理想のdotfiles管理システムの条件：
- **1コマンドセットアップ・管理** - 低い導入コスト
- **マシン差分吸収** - OS（macOS/Linux/WSL）・クラス別に環境を整える
- **シークレット保護** - [1Password でゼロトラスト](.config/op/README.md)
- **XDG 準拠** - ホームディレクトリをクリーンに
- **冪等性** - 何度実行しても同じ結果

dotfiles管理の3つのアプローチ：
1. **シンボリックリンク** (GNU Stow) → Windows でエッジケースが多い
2. **ファイルコピー** (chezmoi) → Single Source of Truth じゃない
3. **Bare Git** → 管理は最も楽だが誤操作や導入時の上書きが怖い

**yadm** は Bare Git の管理しやすさを保ちつつ、上記の欠点を解決した最適解：

**このdotfilesでの実装**:
- **システムワイドZDOTDIR**: `/etc/zsh/zshenv`で`ZDOTDIR=$HOME/.config/zsh`を設定し、`~/.zshenv`を不要に
- **Git自動化**: `autoSetupRemote`, `ff-only`, `autostash`, `rerere` で安全かつ効率的なワークフロー
- **モダンCLIの統合**: `sd`でsed、`duf`でdf、`dust`でduを置き換え、直感的なコマンド体験
- **履歴の知能化**: atuin（同期可能）とmcfly（ニューラルネット）で最適なコマンド候補を提案
- **1Password統合**: SSH鍵もGPG鍵も不要、全ての認証を1Passwordで一元管理

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
