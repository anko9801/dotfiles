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
git f                                          # fetch --prune（最新情報取得）
git pl                                         # pull（ff-onlyで安全）
git sw -c feature/new                          # ブランチ作成
gitui                                          # 作業しながら差分確認
git cz                                         # 規約に沿ったコミット
git ps                                         # push（autoSetupRemote有効）
gh pr create                                   # プルリクエスト作成

# プロジェクト管理
gh repo create my-project --private --clone    # 新規作成
ghq get github.com/user/repo                   # クローン
cd $(ghq list --full-path | fzf)               # 移動（zoxideでcd拡張）
gibo dump Python Node > .gitignore             # .gitignore生成
git open                                       # ブラウザで開く（gh browse）

# 状態確認
git st                                         # status -sb
git diff                                       # 差分（delta、side-by-side）
git staged                                     # ステージング済み差分
git lg                                         # ログ（グラフ）
git la                                         # 全ブランチログ

# コミット操作
git c                                          # commit（verbose有効）
git cm "message"                               # commit -m
git amend                                      # --amend --no-edit
git undo                                       # reset HEAD~1 --mixed
git unstage <file>                             # reset HEAD --

# ブランチ・リモート
git sw <branch>                                # switch
git sw -                                       # 直前のブランチ
git cleanup                                    # マージ済み削除
git please                                     # --force-with-lease
git contributors                               # 貢献者一覧

# 履歴の編集・取り込み
git rebase -i HEAD~3                           # 対話的リベース（autostash有効）
git cherry-pick <commit>                       # 特定コミット取り込み
git stash -u                                   # 未追跡ファイルも含む
git stash pop                                  # 復元（rebase時は自動）
git df                                         # diff --color-words
```