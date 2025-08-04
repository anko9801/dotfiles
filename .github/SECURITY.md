# Security Policy

## 機密情報の取り扱い方針

このdotfilesでは、**ローカルに機密情報を一切保存しない**ゼロトラストアーキテクチャを採用しています。

### 1. 機密情報の定義

以下は機密情報として扱い、リポジトリにコミットしてはいけません：

- **秘密鍵**: SSH秘密鍵、GPG秘密鍵
- **認証情報**: APIキー、アクセストークン、パスワード
- **クラウドクレデンシャル**: AWS/GCP/Azure認証情報
- **データベース接続情報**: 接続文字列、パスワード
- **個人情報**: メールアドレス、実名（設定による）

### 2. 機密情報の管理方法

#### 1Password による集中管理

全ての機密情報は1Passwordで管理します：

```bash
# SSH鍵 - 1Password SSH Agentを使用
Host *
    IdentityAgent "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"

# 環境変数 - op://参照を使用
DATABASE_URL=op://Personal/MyApp/database/url
API_KEY=op://Personal/MyApp/api/key

# 実行時に解決
op run --env-file=.env -- npm start
```

#### yadm暗号化（オプション）

どうしてもローカルに保存が必要な場合：

```bash
# 暗号化対象に追加
echo ".ssh/config" >> ~/.config/yadm/encrypt
echo ".gitconfig.local" >> ~/.config/yadm/encrypt

# 暗号化
yadm encrypt

# 復号化
yadm decrypt
```

### 3. 予防措置

#### 自動チェック

1. **Git hooks** (`core.hooksPath = ~/.config/git/hooks`)
   - 全Gitリポジトリで自動的に適用
   - gitleaksによる包括的なシークレット検出

2. **yadm pre-commit hook** (`.config/yadm/hooks/pre_commit`)
   - dotfiles専用の追加チェック
   - yadmコマンド使用時のみ適用

3. **GitHub Actions** (`.github/workflows/`)
   - 構文チェック（JSON/YAML/TOML）
   - ShellCheckによるシェルスクリプト検証
   - gitleaksによる継続的なシークレットスキャン

#### 手動チェック

コミット前に必ず確認：

```bash
# ステージングされたファイルの確認
yadm diff --cached

# gitleaksでのローカルスキャン
gitleaks detect --source . --config ~/.config/gitleaks/config.toml
```

### 4. インシデント対応

機密情報を誤ってコミットした場合：

1. **即座にローテーション**: 露出した認証情報を無効化し、新規作成
2. **履歴の削除**: `git filter-branch`または`BFG Repo-Cleaner`で履歴から削除
3. **通知**: 影響を受ける可能性のあるシステムの管理者に通知

### 5. ベストプラクティス

1. **最小権限の原則**: トークンやキーは必要最小限の権限で作成
2. **定期的な監査**: 使用していない認証情報は削除
3. **環境分離**: 本番環境の認証情報は開発環境で使用しない
4. **ローカルファースト**: 可能な限り`op://`参照を使い、実値を保存しない

### 6. 設定例

#### Git設定での機密情報分離

```toml
# ~/.config/git/config (公開)
[user]
    name = anko9801
[core]
    hooksPath = ~/.config/git/hooks  # 全リポジトリで共通のフック
[gpg "ssh"]
    program = op-ssh-sign  # 1Password経由で署名

# ~/.config/git/allowed_signers##template (yadmテンプレート)
# ユーザー固有の署名鍵を管理

# ~/.gitconfig.local (暗号化/gitignore)
[user]
    email = private@example.com
```

#### 環境変数テンプレート

```bash
# .env.example (公開)
DATABASE_URL=op://Personal/MyApp/database/url
API_KEY=op://Personal/MyApp/api/key
SECRET_KEY=op://Personal/MyApp/secret/key

# 使用方法
cp .env.example .env
op run --env-file=.env -- npm start
```

### 7. Windows環境での追加考慮事項

- **Git Bash**: Windows環境ではGit Bashを推奨
- **winget**: パッケージ管理にwingetを使用し、信頼できるソースからのみインストール
- **パス区切り**: Windowsパスでは`\`を使用、Git Bashでは`/`を使用
- **改行コード**: `core.autocrlf = input`で統一

## セキュリティ脆弱性の報告

セキュリティ上の問題を発見した場合は、公開のIssueではなく、直接連絡してください。