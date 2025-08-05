# gitconfig

## 特徴的な設定

```gitconfig
[push]
    autoSetupRemote = true              # push時に自動でupstream設定
    
[pull]  
    ff = only                           # fast-forwardのみ許可（安全）
    
[rebase]
    autostash = true                    # rebase時に自動stash/pop
    
[gpg "ssh"]
    program = op-ssh-sign               # 1PasswordでSSH署名
    
[delta]
    side-by-side = true                 # 差分を左右並列表示
    
[rerere]
    enabled = true                      # コンフリクト解決を記憶
```

## 便利なツール

- **GitUI** - Rust製の高速TUIクライアント
- **delta** - 構文ハイライト付きの差分表示
- **ghq** - リポジトリ管理ツール
- **czg** - Conventional Commits ヘルパー
- **gitleaks** - シークレット検出（pre-commitフック）
- **gibo** - .gitignore テンプレート生成ツール

## よく使う操作

```bash
# 日常フロー
git f                                          # fetch --prune（最新情報取得）
git pl                                         # pull（ff-onlyで安全）
git sw -c feature/new                          # ブランチ作成
gitui                                          # 作業しながら差分確認
czg                                            # コミット作成
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
czg                                            # 規約に沿ったコミット作成
git amend                                      # --amend --no-edit
git undo                                       # reset HEAD~1 --mixed
git unstage <file>                             # reset HEAD --

# ブランチ・リモート
git sw <branch>                                # switch
git sw -                                       # 直前のブランチ
git cleanup                                    # マージ済み削除
git please                                     # --force-with-lease

# 履歴の編集・取り込み
git rebase -i HEAD~3                           # 対話的リベース（autostash有効）
git cherry-pick <commit>                       # 特定コミット取り込み
git stash -u                                   # 未追跡ファイルも含む
git stash pop                                  # 復元（rebase時は自動）
git df                                         # diff --color-words
```
