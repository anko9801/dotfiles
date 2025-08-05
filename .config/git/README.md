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
# 日常フロー
git pull --rebase                              # 作業開始前に最新を取得
git switch -c feature/new                      # ブランチ作成
gitui                                          # 作業しながら差分確認
git add -p                                     # 部分的にステージング
git cz                                         # 規約に沿ったコミット
git ps                                         # プッシュ
gh pr create                                   # プルリクエスト作成

# プロジェクト管理
gh repo create my-project --private --clone    # 新規作成
ghq get github.com/user/repo                   # クローン
cd $(ghq list --full-path | fzf)               # 移動
gibo dump Python Node > .gitignore             # .gitignore生成

# 状態確認
git st                                         # status -sb
git diff                                       # 差分（delta）
git lg                                         # ログ（グラフ）
git blame <file>                               # 行ごとの最終更新者

# コミット操作
git cm "message"                               # commit -m
git amend                                      # --amend --no-edit
git undo                                       # reset HEAD~1 --mixed
git restore --staged <file>                    # ステージング取り消し

# ブランチ・リモート
git sw <branch>                                # switch
git sw -                                       # 直前のブランチ
git cleanup                                    # マージ済み削除
git pl                                         # pull
git please                                     # --force-with-lease

# 履歴・一時保存
git rebase -i HEAD~3                           # 対話的リベース
git cherry-pick <commit>                       # 特定コミット取り込み
git stash -u                                   # 未追跡ファイルも含む
git stash pop                                  # 復元
```