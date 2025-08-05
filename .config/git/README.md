# gitconfig

## 設定・ツール

### 基本設定

```gitconfig
[user]
    email = 12345678+username@users.noreply.github.com  # GitHub noreply
    
[core]
    pager = delta                                       # 美しい差分表示
    
[commit]
    gpgsign = true                                      # SSH署名を有効化
```

### 便利なツール

- **GitUI** - Rust製の高速TUIクライアント
- **delta** - 構文ハイライト付きの差分表示
- **ghq** - リポジトリ管理ツール
- **cz-git** - Conventional Commits ヘルパー
- **gitleaks** - シークレット検出（pre-commitフック）
- **gibo** - .gitignore テンプレート生成ツール

## よく使う操作

```bash
# プロジェクト管理
gh repo create my-project --private --clone   # 新規プロジェクトを作成
ghq get github.com/username/project           # 既存プロジェクトをクローン
cd $(ghq list --full-path | fzf)              # プロジェクト間を高速移動
ghq browse                                     # 現在のリポジトリをブラウザで開く
gibo dump Python > .gitignore                  # .gitignore テンプレートを生成

# 状態確認
git st                                         # 短縮表示
git diff                                       # 差分確認（delta）
gitui                                          # 視覚的に確認

# コミット方法
# 1) GitUI で対話的に（推奨）
gitui
# Tab: パネル移動、a: ステージング、c: コミット、P: プッシュ

# 2) 部分的にステージング
git add -p                                     # 変更を選択
git cz                                         # 規約に沿ったメッセージ

# 3) 素早くコミット
git add .
git cm "feat: 新機能"

# コミット修正
git add forgotten.txt && git amend             # ファイル追加し忘れ
git commit --amend                             # メッセージ変更
git undo                                       # 直前を取り消し

# ブランチ
git switch -c feature/awesome                  # ブランチ作成
git sw main                                    # ブランチ切り替え
git cleanup                                    # マージ済みを削除

# リモート同期
git pull --rebase                              # 最新を取得
git ps                                         # プッシュ
git please                                     # 安全な強制プッシュ

# 履歴
git lg                                         # グラフ表示
git la                                         # 全ブランチ
git rebase -i HEAD~3                           # 履歴整理
```

## トラブルシューティング

```bash
# 間違えたブランチで作業
git stash
git switch correct-branch
git stash pop

# コンフリクト解決
# 1. ファイル編集
# 2. git add resolved.txt
# 3. git rebase --continue

# プライバシー保護
git config user.email "12345678+username@users.noreply.github.com"
```
