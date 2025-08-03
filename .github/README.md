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
- **1コマンドセットアップ** - 管理もシンプル
- **マシン差分吸収** - OS・クラス別の自動適用
- **シークレット保護** - 暗号化・ホワイトリスト管理
- **XDG準拠** - ホームディレクトリをクリーンに
- **冪等性** - 何度実行しても同じ結果

dotfiles管理の3つのアプローチ：
1. **シンボリックリンク** (GNU Stow) → 管理スクリプトが必要
2. **ファイルコピー** (chezmoi) → Single Source of Truthじゃない
3. **Bare Git** (yadm) → 導入は手間だが管理が楽

**yadm**はBare Gitの欠点（導入時マージ問題）を解決し、テンプレート・暗号化・フックまで統合した最適解：

- **テンプレート**: Jinja2構文で動的設定生成（`##template`）
- **Alternates**: OS・クラス・ホスト別ファイル切り替え（`##os.Darwin`, `##class.work`）
- **Classes**: マシンタイプ別パッケージ管理（personal/work/server）
- **Bootstrap**: 自動環境構築スクリプト実行
- **暗号化**: openssl/gpgによる機密ファイル管理
- **Hooks**: pre_commit, post_altなどのイベント駆動処理
- **Git統合**: 通常のgitコマンドがそのまま使用可能

**このdotfilesでの実装**:
- **システムワイドZDOTDIR**: `/etc/zsh/zshenv`でルートの`.zshenv`を排除
- **ワンファイルbootstrap**: OS別スクリプトで依存関係を最適化
- **セキュリティ強化**: bash実装のpre-commit hooks、git-secrets統合
- **クリーンな.gitignore**: ホワイトリスト方式で最小限管理

## ツール構成

**共通**: git, tmux, zsh(zinit), vim/neovim, mise, modern CLI tools (bat, eza, ripgrep, fd, fzf, gh, starship, etc.)

**クラス別**:
- Personal: メディアツール、個人アプリ
- Work: クラウド・コンテナツール、IDE
- Server: 最小構成
