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
   - 秘密鍵の検出とgit-secretsによるパターンマッチング

2. **yadm pre-commit hook** (`.config/yadm/hooks/pre_commit`)
   - dotfiles専用の追加チェック
   - yadmコマンド使用時のみ適用

3. **GitHub Actions** (`.github/workflows/lint.yaml`)
   - 構文チェック（JSON/YAML/TOML）
   - ShellCheckによるシェルスクリプト検証

#### 手動チェック

コミット前に必ず確認：

```bash
# ステージングされたファイルの確認
yadm diff --cached

# 機密情報のパターン検索
yadm diff --cached | grep -E '(BEGIN.*PRIVATE KEY|api_key|password|token)'
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
# ~/.config/git/config (公開・yadmテンプレートで生成)
[user]
    name = anko9801
    signingkey = ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG...
[core]
    hooksPath = ~/.config/git/hooks  # 全リポジトリで共通のフック

# ~/.gitconfig.local (暗号化/gitignore)
[user]
    email = private@example.com
[github]
    token = ghp_xxxxxxxxxxxxxxxxxxxx  # 非推奨 - 1Password Shell Pluginsを使用
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

## セキュリティ脆弱性の報告

セキュリティ上の問題を発見した場合は、公開のIssueではなく、直接連絡してください。