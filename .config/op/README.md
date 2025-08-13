# 1Password によるシークレット管理

[ローカル環境からシークレットを削除](https://efcl.info/2023/01/31/remove-secret-from-local/)する設計により、秘密情報を一切ローカルに保存しません。

## SSH鍵管理

- 1Password SSH Agent: 全ての SSH 秘密鍵を 1Password で管理
- 自動設定: `~/.ssh/config.d/1password` で OS 別のエージェントソケットを自動設定
  - macOS: `~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock`
  - Linux: `~/.1password/agent.sock`
  - WSL: npiperelay経由でWindows側の1Passwordと連携
- ForwardAgent: 全ホストで有効化し、リモートサーバーでも 1Password の鍵を使用可能

## Git コミット署名

- SSH 署名: GPG の代わりに SSH 鍵で Git コミットに署名
- op-ssh-sign: 1Password が提供する署名プログラムを使用
  - macOS: `/Applications/1Password.app/Contents/MacOS/op-ssh-sign`
  - Linux/WSL: `op-ssh-sign`
- allowed_signers: `~/.config/git/allowed_signers` で信頼する署名者を管理
- 自動検証: 署名されたコミットを自動的に検証

## CLI ツール認証 (Shell Plugins)

1Password Shell Plugins により、各種 CLI ツールの認証情報を安全に管理：

- GitHub CLI (`gh`): Personal Access Token を 1Password で管理
- AWS CLI: Access Key/Secret Key を安全に保存
- その他対応ツール: 
  - Stripe CLI
  - Vercel CLI
  - Netlify CLI
  - CircleCI CLI
  - など多数

設定は `~/.config/op/plugins.sh` で自動化され、bootstrap 時に適用されます。

## 環境変数の安全な管理

`.env` ファイルで秘密情報を直接記載する代わりに、1Password への参照を使用します：

### 従来の危険な方法
```bash
# .env
API_KEY=sk_test_1234567890abcdef  # 危険！Git に入ってしまう
```

### 1Password を使った安全な方法
```bash
# .env
API_KEY="op://Personal/MyApp/api/key"
DATABASE_URL="op://Personal/MyApp/database/url"
AWS_ACCESS_KEY_ID="op://Personal/AWS/access_key_id"
AWS_SECRET_ACCESS_KEY="op://Personal/AWS/secret_access_key"
```

### 使い方
```bash
# 1Password が自動的に参照を実際の値に置き換えて実行
op run --env-file="./.env" -- npm start
op run --env-file="./.env" -- docker compose up
```

### 1Password でのアイテム作成
```bash
# 新しいアイテムを作成
op item create --category=login --title='MyApp' --vault='Personal'

# フィールドを追加・編集
op item edit 'MyApp' api.key="your-actual-api-key"
op item edit 'MyApp' database.url="postgresql://..."
```

## セキュリティ強化

- pre-commit hooks: `.config/git/hooks/pre-commit` で秘密情報の誤コミットを防止
  - gitleaks による包括的なシークレット検出 (git-secretsから移行)
  - API キー、トークン、秘密鍵のパターンマッチング
  - カスタムルール設定 (`~/.config/gitleaks/config.toml`)
- ゼロトラスト: ローカルに秘密情報を一切保存しないアーキテクチャ
- 監査証跡: 1Password のアクティビティログで全てのアクセスを追跡可能

## 機密情報の定義

以下は機密情報として扱い、リポジトリにコミットしてはいけません：

- 秘密鍵: SSH秘密鍵、GPG秘密鍵
- 認証情報: APIキー、アクセストークン、パスワード
- クラウドクレデンシャル: AWS/GCP/Azure認証情報
- データベース接続情報: 接続文字列、パスワード
- 個人情報: メールアドレス、実名（設定による）

## インシデント対応

機密情報を誤ってコミットした場合：

1. 即座にローテーション: 露出した認証情報を無効化し、新規作成
2. 履歴の削除: `git filter-branch`または`BFG Repo-Cleaner`で履歴から削除
3. 通知: 影響を受ける可能性のあるシステムの管理者に通知

## ベストプラクティス

1. 最小権限の原則: トークンやキーは必要最小限の権限で作成
2. 定期的な監査: 使用していない認証情報は削除
3. 環境分離: 本番環境の認証情報は開発環境で使用しない
4. ローカルファースト: 可能な限り`op://`参照を使い、実値を保存しない