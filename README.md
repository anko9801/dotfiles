# dotfiles

chezmoi で管理する個人用dotfiles

## 特徴

- macOS/Linux対応
- chezmoi テンプレートでOS差分を自動処理
- XDG Base Directory準拠
- 1Password連携（SSH Agent、CLI）

## インストール

```bash
# 1. chezmoi をインストール
brew install chezmoi  # macOS
# or
sudo apt install chezmoi  # Ubuntu

# 2. dotfiles を取得
chezmoi init https://github.com/anko9801/dotfiles.git

# 3. 変更内容を確認
chezmoi diff

# 4. 適用
chezmoi apply
```

## 含まれる設定

- **Shell**: zsh, starship プロンプト
- **Editor**: vim
- **Git**: SSH署名、エイリアス設定
- **Tools**: tmux, mise (バージョン管理)
- **1Password**: SSH Agent連携、CLI設定

## 使い方

```bash
# 設定を編集
chezmoi edit ~/.zshenv

# 変更を確認
chezmoi diff

# 変更を適用
chezmoi apply

# 最新版を取得・適用
chezmoi update
```

## 1Password設定

初回セットアップ後：

1. 1Password アプリでSSH Agentを有効化
2. `op account add` でアカウントを追加
3. `op signin` でサインイン

SSH鍵は1Passwordで管理され、自動的に使用されます。