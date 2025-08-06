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
- **シークレットの安全管理** - SSH 鍵や API キーはパスワードマネージャーで管理、ローカルには置かない
- **クリーンな構成** - XDG Base Directory 準拠で .config に収納
- **環境の再現性** - 必要なツールはすべて宣言的に管理、どこでも同じ環境を構築
- **冪等性** - 何度実行しても既存の設定を壊さない

最も条件を満たすのは Nix かと思いますがガベコレの運用コストが高いので断念。
実装の工夫で冪等性を満たし、宣言的で再現可能にします。


### こだわりポイント

- **シェルもXDG準拠** - `/etc/zshenv` (macOS) や `/etc/zsh/zshenv` (Linux) に設定を書き込むことで .config に収納
- **1Passwordで認証管理** - SSH 鍵、GPG 鍵、API トークンを安全に管理。詳細は [op/README.md](../.config/op/README.md) を参照
- **高速な起動時間** - Sheldon による並列プラグイン読み込みと遅延ロード、不要な処理の削減で zsh 起動を最適化
- **冪等性を重視** - 中断しても再実行したら同じ環境が構成できる。詳細は [yadm/README.md](../.config/yadm/README.md) 参照
- **宣言的な依存管理** - mise で言語バージョン、Brewfile でシステムツール、plugins.toml でシェルプラグインを一元管理

## Tools

- **Shell**: zsh + sheldon
- **Multiplexer**: tmux + TPM
- **Editor**: Vim + dpp.vim, Neovim + lazy.nvim
- **Version Management**: mise (Node.js, Go, Rust, Ruby, Deno, Bun)
- **Python**: uv, ruff
- **Git**: git + delta, gitui, ghq, gibo, git-lfs, gitleaks
- **Modern CLI**: bat, eza, ripgrep, fd, fzf, gh, starship, zoxide, atuin, mcfly, duf, dust, tokei, sd, bottom, gomi
- **AI Assistant**: Claude Code, Gemini CLI



**macOS Specific**:
- **Window Manager**: yabai + skhd
- **Launcher**: Raycast
- **Window Management**: Rectangle
