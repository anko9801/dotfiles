# Git 設定ディレクトリ

このディレクトリには XDG Base Directory 仕様に従った Git 設定ファイルが含まれています。

## 目次

1. [ファイル構成](#ファイル構成)
2. [実際の Git 設定](#実際の-git-設定)
3. [セキュリティ](#セキュリティ)
4. [効率的な Git ワークフロー](#効率的な-git-ワークフロー)
5. [便利なツール](#便利なツール)

## ファイル構成

### `config##template`
メインの Git 設定ファイル（yadm テンプレート）：
- ユーザー設定（名前、メールアドレス）
- コア設定（エディタ、ページャー、フックパス）
- コミットの SSH 署名設定
- よく使う操作のエイリアス
- カラーと UI の設定
- OS 別設定ファイルのインクルード

### `allowed_signers`
コミット署名を許可する SSH 公開鍵。形式：
```
email@example.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAA...
```

### `hooks/pre-commit`
全リポジトリに適用されるグローバル Git フック：
- gitleaks を使用してシークレットを含むコミットを防止
- `git commit --no-verify` でバイパス可能（注意して使用）

### `ghq.toml`
ghq (Git リポジトリ管理ツール) の設定ファイル

## 実際の Git 設定

### 基本設定

#### ユーザー情報
```gitconfig
[user]
    name = {{ yadm.user }}     # yadm テンプレートで自動設定
    email = {{ yadm.email }}    # GitHub noreply 推奨
    signingkey = {{ yadm.signingkey }}  # SSH 署名用の公開鍵
```

#### エディタとページャー
```gitconfig
[core]
    editor = vim
    pager = delta              # 美しい差分表示
    hooksPath = ~/.config/git/hooks  # グローバルフック
```

### セキュリティ設定

#### SSH 署名（1Password 統合）
```gitconfig
[commit]
    gpgsign = true             # 全てのコミットに署名

[gpg]
    format = ssh               # SSH 鍵で署名
[gpg "ssh"]
    program = /Applications/1Password.app/Contents/MacOS/op-ssh-sign  # macOS
    # program = op-ssh-sign    # Linux/WSL
    allowedSignersFile = ~/.config/git/allowed_signers
```

#### オブジェクト整合性
```gitconfig
[fetch]
    fsckobjects = true
[transfer]
    fsckobjects = true
[receive]
    fsckObjects = true
```

### ワークフロー設定

#### ブランチ戦略
```gitconfig
[init]
    defaultBranch = main
[pull]
    ff = only                  # fast-forward のみ許可
[push]
    autoSetupRemote = true     # 自動的にリモートを設定
    default = current          # 現在のブランチをプッシュ
[rebase]
    autostash = true           # リベース時に自動スタッシュ
```

### 便利なエイリアス

```gitconfig
# 基本操作
st = status -sb
co = checkout
sw = switch
br = branch

# コミット
c = commit
cm = commit -m
amend = commit --amend --no-edit
undo = reset HEAD~1 --mixed

# リモート操作
ps = push
pl = pull
please = push --force-with-lease

# ログ表示
lg = log --oneline --graph --decorate
la = log --oneline --graph --decorate --all

# ブランチ管理
cleanup = !git branch --merged | grep -v "\\*\\|main\\|master" | xargs -n 1 git branch -d
```

## セキュリティ

### シークレット検出

pre-commit フックは gitleaks を使用して以下を防止：
- AWS 認証情報
- API キーとトークン
- SSH/GPG 秘密鍵
- データベース接続文字列

カスタムルールは `~/.config/gitleaks/config.toml` で設定可能。

### メールアドレスのプライバシー保護

#### GitHub の noreply メールアドレスを使用
```bash
# 形式: <ID>+<username>@users.noreply.github.com
git config --global user.email "12345678+yourusername@users.noreply.github.com"
```

確認先: https://github.com/settings/emails

#### 既存コミットの修正（危険）
```bash
# 今後のコミットのみ変更
git config user.email "12345678+username@users.noreply.github.com"

# 履歴書き換え（共同作業者と要調整）
git filter-branch --env-filter '...' --tag-name-filter cat -- --branches --tags
```

## 効率的な Git ワークフロー

### 1. リポジトリ管理（ghq + fzf）

```bash
# 新規作成
gh repo create my-project --private
ghq get github.com/username/my-project

# 高速切り替え
cd $(ghq list --full-path | fzf)
```

### 2. コミット作成（gitui / git add -p + cz-git）

```bash
# 対話的な差分確認とステージング（TUI）
gitui

# または部分的なステージング（コマンドライン）
git add -p

# 規約に沿ったコミットメッセージ
git cz
```

### 3. コミット履歴の整理

```bash
# 直前のコミット修正（gitui で A）
git commit --amend

# fixup コミット（gitui で F）
git commit --fixup <commit-hash>
git rebase -i --autosquash
```

## 便利なツール

### GitUI - TUI Git クライアント

高速な Rust 製 Git クライアント。主な操作：
- `Tab`: パネル移動
- `Enter`: 差分表示
- `a`: ステージング
- `c`: コミット
- `P`: プッシュ

### cz-git - Conventional Commits

インストール：
```bash
npm install -g cz-git commitizen
git config --global alias.cz "!npx cz"
```

### Git Delta - 美しい差分表示

設定：
```gitconfig
[core]
    pager = delta

[delta]
    navigate = true
    side-by-side = true
    line-numbers = true
    syntax-theme = Monokai Extended
```

## トラブルシューティング

### よくある問題

1. **署名エラー**: 1Password の SSH Agent が有効か確認
2. **フック実行エラー**: 実行権限を確認 (`chmod +x`)
3. **delta 表示エラー**: `bat --list-themes` でテーマ確認

### 設定の確認

```bash
# 現在の設定を表示
git config --list --show-origin

# 特定の設定を確認
git config user.email
```