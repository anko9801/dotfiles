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
- **シークレット保護** - 1Password にまとめる
- **XDG 準拠** - ホームディレクトリをクリーンに
- **冪等性** - 何度実行しても同じ結果

dotfiles管理の3つのアプローチ：
1. **シンボリックリンク** (GNU Stow) → Windows でエッジケースが多い
2. **ファイルコピー** (chezmoi) → Single Source of Truth じゃない
3. **Bare Git** → 管理は最も楽だが誤操作や導入時の上書きが怖い

**yadm** は Bare Git の管理しやすさを保ちつつ、上記の欠点を解決した最適解：

**このdotfilesでの実装**:
- **システムワイドZDOTDIR**: `/etc/zsh/zshenv`で`ZDOTDIR=$HOME/.config/zsh`を設定し、`~/.zshenv`を不要に
- **セキュリティ強化**: `core.hooksPath`による一元的なGitフック管理、gitleaks統合
- **クリーンな .gitignore**: ホワイトリスト方式で最小限管理
- **テンプレート化**: yadmテンプレートでOS/クラス別の設定を効率的に管理
- **Windows対応**: wingetによるパッケージ管理とGit Bashサポート

### 1Password によるシークレット管理

[ローカル環境からシークレットを削除](https://efcl.info/2023/01/31/remove-secret-from-local/)する設計により、秘密情報を一切ローカルに保存しません：

#### SSH鍵管理
- **1Password SSH Agent**: 全ての SSH 秘密鍵を 1Password で管理
- **自動設定**: `~/.ssh/config.d/1password` で OS 別のエージェントソケットを自動設定
  - macOS: `~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock`
  - Linux: `~/.1password/agent.sock`
  - WSL: npiperelay経由でWindows側の1Passwordと連携
- **ForwardAgent**: 全ホストで有効化し、リモートサーバーでも 1Password の鍵を使用可能

#### Git コミット署名
- **SSH 署名**: GPG の代わりに SSH 鍵で Git コミットに署名
- **op-ssh-sign**: 1Password が提供する署名プログラムを使用
  - macOS: `/Applications/1Password.app/Contents/MacOS/op-ssh-sign`
  - Linux/WSL: `op-ssh-sign`
- **allowed_signers**: `~/.config/git/allowed_signers` で信頼する署名者を管理
- **自動検証**: 署名されたコミットを自動的に検証

#### CLI ツール認証 (Shell Plugins)
1Password Shell Plugins により、各種 CLI ツールの認証情報を安全に管理：
- **GitHub CLI (`gh`)**: Personal Access Token を 1Password で管理
- **AWS CLI**: Access Key/Secret Key を安全に保存
- **その他対応ツール**: 
  - Stripe CLI
  - Vercel CLI
  - Netlify CLI
  - CircleCI CLI
  - など多数

設定は `~/.config/op/plugins.sh` で自動化され、bootstrap 時に適用されます。

#### 環境変数の安全な管理
`.env` ファイルで秘密情報を直接記載する代わりに、1Password への参照を使用します：

**従来の危険な方法**:
```bash
# .env
API_KEY=sk_test_1234567890abcdef  # 危険！Git に入ってしまう
```

**1Password を使った安全な方法**:
```bash
# .env
API_KEY="op://Personal/MyApp/api/key"
DATABASE_URL="op://Personal/MyApp/database/url"
AWS_ACCESS_KEY_ID="op://Personal/AWS/access_key_id"
AWS_SECRET_ACCESS_KEY="op://Personal/AWS/secret_access_key"
```

**使い方**:
```bash
# 1Password が自動的に参照を実際の値に置き換えて実行
op run --env-file="./.env" -- npm start
op run --env-file="./.env" -- docker compose up
```

**1Password でのアイテム作成**:
```bash
# 新しいアイテムを作成
op item create --category=login --title='MyApp' --vault='Personal'

# フィールドを追加・編集
op item edit 'MyApp' api.key="your-actual-api-key"
op item edit 'MyApp' database.url="postgresql://..."
```


#### セキュリティ強化
- **pre-commit hooks**: `.config/git/hooks/pre-commit` で秘密情報の誤コミットを防止
  - gitleaks による包括的なシークレット検出 (git-secretsから移行)
  - API キー、トークン、秘密鍵のパターンマッチング
  - カスタムルール設定 (`~/.config/gitleaks/config.toml`)
- **ゼロトラスト**: ローカルに秘密情報を一切保存しないアーキテクチャ
- **監査証跡**: 1Password のアクティビティログで全てのアクセスを追跡可能

## ツール構成

**共通ツール**:
- **バージョン管理**: mise (全OS共通でcurl経由インストール)
- **シェル**: zsh + antidote (プラグイン管理)
- **エディタ**: vim/neovim
- **開発ツール**: git (core.hooksPath設定済み), tmux, gitleaks
- **Modern CLI**: bat, eza, ripgrep, fd, fzf, gh, starship, zoxide, atuin, delta
- **Python**: uv (パッケージマネージャー), ruff (リンター)

**OS別対応**:
- **macOS**: Homebrew経由でツールインストール
- **Linux**: apt/pacman/dnf + 最新版は.debファイルから
- **WSL**: Windows連携ツール (pbcopy/pbpaste, explorer統合)
- **Windows**: winget経由でツールインストール、Git Bash環境

**クラス別構成**:
- **Personal**: メディアツール (ffmpeg, yt-dlp)、個人アプリ (Obsidian, Spotify)
- **Work**: クラウド・コンテナツール (AWS CLI, terraform, kubectl, docker)
- **Server**: 最小構成（基本ツールのみ）
