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

新しいマシンでもコマンド一発でいつもの環境を再現したい。理想としてはこんな感じ:

- **1コマンドで完結** - 複雑な手順や事前準備は不要
- **XDG Base Directory 準拠** - 全ての設定を .config 内に収納
- **シークレットの安全管理** - SSH 鍵や API キーはパスワードマネージャーで管理、ローカルには置かない
- **環境を自動判別** - OS (macOS/Linux/WSL/Windows) やコンテキスト (work/personal) に応じた設定
- **環境の再現性** - 必要なツールはすべて宣言的に管理、どこでも同じ環境を構築
- **冪等性** - 何度実行しても既存の設定を壊さない

最も条件を満たすのは Nix かと思いますがガベコレの運用コストが高いので断念。
実装の工夫で冪等性を満たし、宣言的で再現可能にします。


### こだわりポイント

- **yadm によるシンプルな管理** - yadm bootstrap を叩くだけ (ref. [なぜyadm？](../.config/yadm/README.md))
- **シェルもXDG準拠** - `/etc/zshenv` (macOS) や `/etc/zsh/zshenv` (Linux) に設定を書き込むことで .config に収納
- **1Passwordで認証管理** - SSH 鍵、GPG 鍵、API トークンを安全に管理 (ref: [op/README.md](../.config/op/README.md))
- **冪等性** - インストールや設定の前にチェック (ref. [冪等なシェルスクリプトのベストプラクティス](../.config/yadm/README.md))
- **宣言的なパッケージ管理** - [packages.yaml](../.config/yadm/packages.yaml), [Brewfile](../.config/yadm/Brewfile), [mise/config.toml](../.config/mise/config.toml) を使う


## Tools

- **Shell**: zsh + sheldon
- **Multiplexer**: tmux + TPM
- **Editor**: Vim + dpp.vim, Neovim + lazy.nvim
- **Version Management**: mise (Node.js, Go, Rust, Ruby, Deno, Bun)
- **Python**: uv, ruff
- **Git**: git, delta, gitui, ghq, gibo, git-lfs, gitleaks
- **Modern CLI**: bat, eza, ripgrep, fd, fzf, gh, starship, zoxide, atuin, mcfly, duf, dust, tokei, sd, bottom, gomi
- **AI Assistant**: Claude Code, Gemini CLI


**macOS Specific**:
- **Window Manager**: yabai + skhd
- **Launcher**: Raycast
