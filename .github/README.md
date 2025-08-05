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

### 何を目指すか

**開発効率の最大化** - 環境構築は価値を生まない。本質的な作業に集中できる環境を即座に用意する。

### 設計原則

1. **ゼロフリクション** - 新しいマシンでも10分以内に普段の開発環境を再現
2. **プログレッシブ・エンハンスメント** - 基本機能は確実に動作し、モダンツールで段階的に体験を向上
3. **セキュア・バイ・デフォルト** - 秘密情報は一切ローカルに保存せず、1Passwordで中央管理
4. **コンテキスト・アウェア** - work/personalなど状況に応じた最適な設定を自動適用

### 技術選定の理由

**yadm を選んだ理由**:
- Gitの知識だけで管理可能（学習コスト最小）
- テンプレート機能でマシン差分を吸収
- 既存ファイルの上書きを防ぐ安全設計
- シンプルさと柔軟性のバランス

**実装のハイライト**:
- **インテリジェントな履歴管理**: atuin（クラウド同期）+ mcfly（機械学習）で過去のコマンドを賢く活用
- **直感的なコマンド体験**: `sd`（sed代替）、`duf`（df代替）など、覚えやすく使いやすいツールを標準化
- **Git操作の自動化**: `autoSetupRemote`、`rerere`などで繰り返し作業を削減
- **統一されたツール管理**: miseで言語・ツールのバージョンを一元管理、チーム間の環境差異を解消

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
