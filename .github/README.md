# dotfiles

```bash
# インストール
brew install yadm                # macOS
sudo apt install -y yadm         # Ubuntu/Debian  
sudo pacman -S --noconfirm yadm  # Arch Linux

# セットアップ
yadm clone https://github.com/anko9801/dotfiles
yadm status && yadm diff         # 既存設定がある場合は競合確認
yadm reset --hard origin/master  # 必要に応じて既存設定を破棄
yadm bootstrap
```

## コンセプト

新しいマシンでもコマンド一発でいつもの環境を再現したい。理想としてはこんな感じ:

- **らくちん** - 1コマンドでセットアップ&管理
- **ミニマル** - .config にすべて収納
- **シークレット管理** - SSH 鍵や API キーはパスワードマネージャーで管理、ローカルには置かない
- **マシン差分を吸収** - OS (macOS/Linux/WSL/Windows) やコンテキスト (work/personal) に応じた設定
- **再現性** - 必要なツールはすべて宣言的に管理、どこでも同じ環境を構築
- **冪等性** - 何度実行しても既存の設定を壊さない

最も条件を満たすのは Nix かと思いますがガベコレの運用コストが高いので断念。
実装の工夫で冪等性を満たして、宣言的で再現可能にしてみました。


### こだわりポイント

- **yadm によるシンプルな管理** - [なぜyadm？](../.config/yadm/README.md)
- **シェルも収納** - `/etc/zsh/zshenv` で XDG Base Directory 準拠することで .zshrc も .config に収納
- **1Passwordで認証管理** - SSH 鍵、GPG 鍵、API トークンを安全に管理 - [op/README.md](../.config/op/README.md)
- **冪等性** - [冪等なシェルスクリプトのベストプラクティス](../.config/yadm/README.md)
- **宣言的なパッケージ管理** - [Brewfile](../.config/yadm/Brewfile) [mise](../.config/mise/config.toml) で扱えないものは [packages.yaml](../.config/yadm/packages.yaml) で宣言
- **顔文字プロンプト** - いつもは `╰─(*'-') ❯` エラーが出たら `╰─(*;-;) ❯`


## Tools

- **Shell**: zsh + sheldon
- **Multiplexer**: tmux + TPM
- **Editor**: Vim + dpp.vim, Neovim + lazy.nvim
- **dev env**: mise (Node.js, Go, Rust, Ruby, Deno, Bun)
- **Python**: uv, ruff
- **Git**: git, delta, gitui, ghq, gibo, git-lfs, gitleaks
- **Modern CLI**: bat, eza, ripgrep, fd, fzf, gh, starship, zoxide, atuin, mcfly, duf, dust, tokei, sd, bottom, gomi
- **AI Assistant**: Claude Code, Gemini CLI


**macOS Specific**:
- **Window Manager**: yabai + skhd
- **Launcher**: Raycast
