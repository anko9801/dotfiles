# yadm 設定ディレクトリ

このディレクトリには、dotfiles を管理するための yadm 固有の設定ファイルとスクリプトが含まれています。

## ファイル構成

### `bootstrap`
`yadm clone` 後に実行されるメインセットアップスクリプト。dotfiles セットアップ全体を統括します：
- XDG ディレクトリのセットアップ
- yadm インストールの検証
- OS/クラス固有のインストールスクリプトの実行
- インストール後タスクの実行

### `install##template`
異なる OS やマシンクラスに適応するテンプレートベースのインストーラー：
- yadm のテンプレートエンジンを使用して OS 固有の設定を生成
- サポート OS: macOS、Linux (Ubuntu/Debian/Arch)、WSL、Windows (Git Bash)
- パッケージのインストール、ツールの設定、開発環境のセットアップ

テンプレート変数:
- `yadm.os`: オペレーティングシステム (Darwin, Linux, Windows)
- `yadm.class`: マシンクラス (personal, work, server)
- `yadm.hostname`: マシンのホスト名
- `yadm.user`: 現在のユーザー名

### `hooks/`
さまざまな git 操作に対する yadm フック：
- `pre_commit`: コミット前に実行（現在はグローバル git フックを使用）
- `post_checkout`: クローン後のタスクに使用可能
- `post_merge`: プル後のタスクに使用可能

## 使い方

### 手動ブートストラップ
```bash
yadm bootstrap
```

### マシンクラスの設定
```bash
yadm config local.class personal  # または work, server
```

### テンプレートのテスト
```bash
# 実行せずにテンプレート出力を生成
yadm alt
```

### 新しい OS サポートの追加
1. `install##template` に新しい OS 検出を追加
2. パッケージマネージャーのセットアップを実装
3. OS 固有のパッケージインストールを追加
4. テスト: `yadm bootstrap`

## テンプレート構文

yadm はシンプルなテンプレート構文を使用します：
```bash
{% if yadm.os == "Darwin" %}
    # macOS 固有のコード
{% endif %}

{% if yadm.class == "work" %}
    # 仕事用マシン固有のコード
{% endif %}
```

注意: yadm は `elif` をサポートしていません。代わりに個別の `if` ブロックを使用してください。

## 冪等なシェルスクリプトのベストプラクティス

bootstrap および install スクリプトは何度実行しても安全であるよう、冪等性を保つことが重要です。

### ファイル操作

```bash
# ディレクトリ作成
mkdir -p "$HOME/.config"

# ファイル作成（存在確認付き）
[ ! -f "$file" ] && touch "$file"

# シンボリックリンク
ln -sfn "$source" "$target"

# ファイルコピー（常に冪等）
cp -af "$source" "$destination"  # -f: 強制上書き

# ファイル削除（常に冪等）
rm -f "$file"     # ファイルが存在しなくてもエラーなし
rm -rf "$dir"     # ディレクトリが存在しなくてもエラーなし

# バックアップ
[ -f "$file" ] && cp -a "$file" "$file.bak.$(date +%Y%m%d_%H%M%S)"

# 行の冪等な追加
grep -Fxq "$line" "$file" || echo "$line" >> "$file"

# sed の基本（-iで直接編集）
sed -i 's/old/new/g' "$file"        # 直接編集
sed -i.bak 's/old/new/g' "$file"    # .bakでバックアップ

# 冪等なsed（条件付き実行）
grep -q "pattern" "$file" && sed -i 's/pattern/replacement/g' "$file"

# キー=値 形式の設定更新
update_config() {
    local key="$1" value="$2" file="$3"
    if grep -q "^${key}=" "$file"; then
        sed -i "s/^${key}=.*/${key}=${value}/" "$file"
    else
        echo "${key}=${value}" >> "$file"
    fi
}

# 設定ブロックの追加
add_config_block() {
    local marker="$1" file="$2"
    shift 2
    if ! grep -qF "$marker" "$file"; then
        echo -e "\n$marker\n$*" >> "$file"
    fi
}

# アトミックな更新（大きな変更や重要なファイル向け）
cp "$file" "$file.tmp" && {
    sed 's/old/new/g' "$file.tmp" > "$file"
    rm "$file.tmp"
}
```

### パッケージ管理

```bash
# 汎用的で効率的な一括パッケージインストール
install_packages() {
    if command -v apt &>/dev/null; then
        sudo apt install -y "$@"
    elif command -v pacman &>/dev/null; then
        sudo pacman -S --needed --noconfirm "$@"
    elif command -v dnf &>/dev/null; then
        sudo dnf install -y "$@"
    elif command -v zypper &>/dev/null; then
        sudo zypper install -y "$@"
    elif command -v apk &>/dev/null; then
        sudo apk add --no-cache "$@"
    fi
}

# 使用例
packages=(
    git curl wget tmux
    neovim ripgrep fd bat
    build-essential python3 nodejs
)
install_packages "${packages[@]}"
```

### サービス管理（systemd）

```bash
# サービスの有効化と起動
ensure_service() {
    local svc="$1"
    systemctl is-enabled --quiet "$svc" || sudo systemctl enable "$svc"
    systemctl is-active --quiet "$svc" || sudo systemctl start "$svc"
}
```

### エラーハンドリングと安全性

```bash
#!/bin/bash
set -euo pipefail
# -e: エラーで即座に終了
# -u: 未定義変数でエラー
# -o pipefail: パイプライン内のエラーを検知

# クリーンアップ処理
TEMP_FILES=()
cleanup() {
    local exit_code=$?
    # 一時ファイルの安全な削除
    for file in "${TEMP_FILES[@]}"; do
        [[ -f "$file" ]] && rm -f "$file"
    done
    # 一時ディレクトリの削除
    [[ -d "$TEMP_DIR" ]] && rm -rf "$TEMP_DIR"
    
    [[ $exit_code -ne 0 ]] && echo "エラー発生。クリーンアップ完了。"
}
trap cleanup EXIT INT TERM

# 一時ファイルの作成と登録
temp_file=$(mktemp)
TEMP_FILES+=("$temp_file")

# 排他制御（重複実行防止）
(
    flock -n 200 || { echo "既に実行中"; exit 1; }
    # メイン処理
) 200>/var/lock/myscript.lock
```

### 確認コマンド一覧

| 対象 | 確認方法 | 説明 |
|------|---------|------|
| **ファイル・ディレクトリ** |
| ディレクトリ | `[ -d "$dir" ]` | ディレクトリか確認 |
| ファイル | `[ -f "$file" ]` | 通常ファイルか確認 |
| 存在確認 | `[ -e "$path" ]` | 何かが存在するか確認 |
| シンボリックリンク | `[ -L "$link" ]` | シンボリックリンクか確認 |
| 読み取り可能 | `[ -r "$file" ]` | 読み取り権限の確認 |
| 書き込み可能 | `[ -w "$file" ]` | 書き込み権限の確認 |
| 実行可能 | `[ -x "$file" ]` | 実行権限の確認 |
| **文字列・内容** |
| 文字列が空でない | `[ -n "$str" ]` | 文字列に内容があるか |
| 文字列が空 | `[ -z "$str" ]` | 文字列が空か |
| ファイル内検索 | `grep -q "pattern" "$file"` | パターンが存在するか |
| 完全一致行検索 | `grep -Fxq "$line" "$file"` | 行が完全一致で存在するか |
| **コマンド・パッケージ** |
| コマンド | `command -v "$cmd" &>/dev/null` | コマンドが利用可能か |
| which（非推奨） | `which "$cmd" &>/dev/null` | command -v を使うべき |
| Debian/Ubuntu | `dpkg -l "$pkg" &>/dev/null` | パッケージ確認 |
| Arch Linux | `pacman -Qi "$pkg" &>/dev/null` | パッケージ確認 |
| RedHat系 | `rpm -q "$pkg" &>/dev/null` | パッケージ確認 |
| **サービス・プロセス** |
| サービス有効 | `systemctl is-enabled --quiet "$svc"` | 自動起動が有効か |
| サービス実行中 | `systemctl is-active --quiet "$svc"` | 現在実行中か |
| プロセス | `pgrep "$process" &>/dev/null` | プロセスが実行中か |
| ポート | `netstat -tln | grep -q ":$port "` | ポートが使用中か |
| **ユーザー・権限** |
| ユーザー | `id "$user" &>/dev/null` | ユーザーが存在するか |
| グループ | `getent group "$grp" &>/dev/null` | グループが存在するか |
| root権限 | `[ $EUID -eq 0 ]` | rootで実行中か |

### チェックリスト

- [ ] `mkdir` → `mkdir -p` に変更
- [ ] `ln -s` → `ln -sfn` に変更
- [ ] `cp` → `cp -af` でシンプルに
- [ ] `rm` → `rm -f` / `rm -rf` でエラー抑制
- [ ] ファイル追記前に `grep` で重複確認
- [ ] `sed -i` は条件付きで使用（必要な場合のみ）
- [ ] パッケージマネージャーの冪等性を活用
- [ ] スクリプト冒頭に `set -euo pipefail`
- [ ] 必要に応じて `trap` でクリーンアップ

### 実例：Before/After

```bash
# ❌ 非冪等な例
mkdir /opt/myapp                           # 既存時にエラー
sudo apt install nginx                     # 実は冪等（パッケージマネージャーが処理）
ln -s /etc/nginx/sites-available/mysite    # 既存時にエラー
echo "PATH=/usr/local/bin:$PATH" >> ~/.bashrc  # 重複追加
cp config.conf /etc/myapp/                 # 実は冪等（上書きするだけ）
rm /tmp/oldfile                            # ファイルなしでエラー

# ✅ シンプルで冪等な例
mkdir -p /opt/myapp                        # 常に成功
sudo apt install -y nginx                  # パッケージマネージャーは冪等
ln -sfn /etc/nginx/sites-available/mysite /etc/nginx/sites-enabled/mysite
grep -Fxq 'PATH=/usr/local/bin:$PATH' ~/.bashrc || echo 'PATH=/usr/local/bin:$PATH' >> ~/.bashrc
cp -af config.conf /etc/myapp/             # -f で強制上書き
rm -f /tmp/oldfile                         # -f でエラー抑制
```

## 冪等性の原則

1. **確認してから実行**：現在の状態をチェックしてから変更
2. **差分のみ適用**：必要な変更だけを実行
3. **エラーを適切に処理**：既に完了している操作は `|| true` で無視
4. **アトミックに操作**：中途半端な状態を避ける

冪等性により「何度実行しても安全」が保証され、信頼性の高い自動化を実現できます。