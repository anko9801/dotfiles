# Zsh Abbreviations (zsh-abbr)

このプロジェクトでは、zsh-abbrを使用してシェルの入力を効率化しています。

## 使い方

abbreviationを入力してスペースを押すと、自動的に展開されます。

例:
```bash
$ g<space>     # → git
$ gst<space>   # → git st
$ ll<space>    # → eza -l
```

## 設定されているabbreviations

### Git操作
- `g` → `git`
- `gst` → `git st` (status)
- `gsw` → `git sw` (switch)
- `gf` → `git f` (fetch)
- `gpl` → `git pl` (pull)
- `gps` → `git ps` (push)
- `glg` → `git lg` (log graph)
- `gdf` → `git df` (diff)
- `gcz` → `czg` (conventional commits)

### ファイル操作
- `ls` → `eza` (モダンなls)
- `ll` → `eza -l` (詳細表示)
- `la` → `eza -la` (隠しファイル含む)
- `lt` → `eza --tree` (ツリー表示)
- `cat` → `bat` (シンタックスハイライト付き)
- `find` → `fd` (高速find)
- `grep` → `rg` (ripgrep)
- `rm` → `gomi` (ゴミ箱へ移動)

### ナビゲーション
- `..` → `cd ..`
- `...` → `cd ../..`
- `....` → `cd ../../..`
- `dot` → `cd ~/workspace/projects/dotfiles`
- `pj` → `cd ~/workspace/projects`

### Docker
- `d` → `docker`
- `dc` → `docker-compose`
- `dps` → `docker ps`
- `dpsa` → `docker ps -a`

### パッケージ管理
- `bi` → `brew install`
- `bu` → `brew update`
- `bug` → `brew upgrade`

### 開発ツール
- `py` → `python3`
- `pip` → `uv pip`
- `venv` → `uv venv`
- `m` → `mise`
- `mi` → `mise install`

### GitHub CLI
- `ghpr` → `gh pr create`
- `ghpv` → `gh pr view`
- `ghpl` → `gh pr list`

### その他
- `v` → `vim`
- `nv` → `nvim`
- `c` → `code`
- `t` → `tmux`
- `reload` → `source $ZDOTDIR/.zshrc`

## 新しいabbreviationの追加

```bash
# セッション限定（一時的）
abbr -S myabbr="my long command"

# 永続的
abbr myabbr="my long command"
```

## 既存のabbreviationの確認

```bash
# 一覧表示
abbr list

# 特定のabbreviationを確認
abbr expand gst
```

## abbreviationの削除

```bash
abbr erase myabbr
```

## トラブルシューティング

もしabbreviationが動作しない場合:

1. 新しいシェルを開くか、`reload`を実行
2. `abbr list`でabbreviationが読み込まれているか確認
3. `which abbr`でzsh-abbrがインストールされているか確認