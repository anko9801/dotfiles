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

新しいマシンでもコマンド一発でいつもの環境を再現したい。理想としてはこんな感じ:

- **1コマンドで完結** - 複雑な手順や事前準備は不要
- **環境を自動判別** - OS (macOS/Linux/WSL/Windows) やコンテキスト (work/personal) に応じた設定
- **シークレットの安全管理** - SSH 鍵や API キーは 1Password で管理、ローカルには置かない
- **クリーンな構成** - XDG Base Directory 準拠で `.config/` に収納
- **環境の再現性** - 必要なツールはすべて宣言的に管理、どこでも同じ環境を構築
- **冪等性** - 何度実行しても既存の設定を壊さない

最も条件を満たすのは Nix かと思いますがガベコレの運用コストが高いので断念。
実装の工夫で冪等性を満たし、宣言的で再現可能にします。

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

- **1Passwordで認証管理** - 詳細は [op/README.md](../.config/op/README.md) を参照
- **シェルもXDG準拠** - `/etc/zsh/zshenv` に設定を書き込むことで .config に収納
- **Claude Code統合** - [kiro](https://github.com/gotalab/claude-code-spec) をサブモジュール化、カスタムコマンドで開発効率化
- **mise による統一的バージョン管理** - 言語やツールのバージョンを一元管理、チーム開発でも環境を完全一致
- **YADM テンプレート活用** - OS・環境別の設定を1ファイルで管理、条件分岐で重複を排除

## ツール構成

**共通ツール**:
- **バージョン管理**: mise
- **シェル**: zsh + sheldon
- **エディタ**: Vim + dpp.vim, Neovim + lazy.nvim
- **ターミナルマルチプレクサ**: tmux + TPM, zellij
- **開発ツール**: git + delta, gitui, ghq, gibo, git-lfs, gitleaks
- **Modern CLI**: bat, eza, ripgrep, fd, fzf, gh, starship, zoxide, atuin, mcfly, duf, dust, tokei, sd, bottom, gomi
- **AI アシスタント**: Claude Code, Gemini CLI
- **Python**: uv, ruff
- **その他言語**: Node.js, Go, Rust, Ruby, Deno, Bun（miseで管理）

**OS別対応**:
- **macOS**: Homebrew経由でツールインストール
- **Linux**: apt/pacman/dnf + 最新版は.debファイルから
- **WSL**: Windows連携ツール (pbcopy/pbpaste, explorer統合)
- **Windows**: winget経由でツールインストール、Git Bash環境

**クラス別構成**:
- **Personal**: メディアツール (ffmpeg, yt-dlp, imagemagick, pandoc)、個人アプリ (Obsidian, Spotify)
- **Work**: クラウド・コンテナツール (AWS CLI, terraform, kubectl, helm, docker-compose)、コミュニケーション (Discord, Slack, Zoom)
- **Server**: 最小構成（基本ツールのみ）

**macOS 専用**:
- **Window Manager**: yabai + skhd
- **ランチャー**: Raycast
- **ウィンドウ管理**: Rectangle
