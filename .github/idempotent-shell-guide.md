# 冪等なシェルスクリプト実践ガイド

## 基本パターン

### ファイルシステム操作

```bash
# ディレクトリ作成
mkdir -p "$HOME/.config"

# ファイル作成（存在確認付き）
[ ! -f "$file" ] && touch "$file"

# シンボリックリンク
ln -sfn "$source" "$target"

# ファイルコピー（常に冪等）
cp -af "$source" "$destination"  # -f: 強制上書き、エラーなし

# ファイル削除（常に冪等）
rm -f "$file"     # ファイルが存在しなくてもエラーなし
rm -rf "$dir"     # ディレクトリが存在しなくてもエラーなし

# バックアップ付き操作
backup_and_replace() {
    local file="$1" new_content="$2"
    [ -f "$file" ] && cp -a "$file" "$file.bak.$(date +%Y%m%d_%H%M%S)"
    echo "$new_content" > "$file"
}

# 行の冪等な追加
grep -Fxq "$line" "$file" || echo "$line" >> "$file"

# 設定ブロックの追加
add_config_block() {
    local marker="$1" file="$2"
    shift 2
    if ! grep -qF "$marker" "$file"; then
        echo -e "\n$marker\n$*" >> "$file"
    fi
}
```

### 設定管理

```bash
# sed によるインプレース編集
# -i: ファイルを直接編集（バックアップなし）
# -i.bak: 編集前のファイルを .bak として保存
sed -i 's/old_pattern/new_pattern/g' "$file"
sed -i.bak 's/old_pattern/new_pattern/g' "$file"  # バックアップ付き

# 冪等な sed 編集（条件付き）
if grep -q "old_pattern" "$file"; then
    sed -i 's/old_pattern/new_pattern/g' "$file"
fi

# キー・バリュー形式の更新
update_config() {
    local key="$1" value="$2" file="$3"
    if grep -q "^${key}=" "$file"; then
        sed -i "s/^${key}=.*/${key}=${value}/" "$file"
    else
        echo "${key}=${value}" >> "$file"
    fi
}

# Git設定の冪等化
git_config_set() {
    local key="$1" value="$2"
    current=$(git config --global "$key" 2>/dev/null || echo "")
    [[ "$current" != "$value" ]] && git config --global "$key" "$value"
}

# アトミックなファイル更新（sed -i の安全な代替）
atomic_update() {
    local file="$1"
    cp -a "$file" "$file.tmp"
    sed 's/old_pattern/new_pattern/g' "$file.tmp"
    mv "$file.tmp" "$file"
}

# 複数行の置換（sed -i の応用）
replace_block() {
    local file="$1" start_marker="$2" end_marker="$3" new_content="$4"
    sed -i "/${start_marker}/,/${end_marker}/c\\
${new_content}" "$file"
}
```

## パッケージ・サービス管理

### パッケージインストール

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

# 注：最新のパッケージマネージャーは内部で並列ダウンロードを最適化しています
# - apt (APT 2.0+): Acquire::Queue-Mode "host"
# - pacman: /etc/pacman.conf で ParallelDownloads = 5
# - dnf: /etc/dnf/dnf.conf で max_parallel_downloads=10
# - zypper: aria2c を使用して並列ダウンロード

### サービス管理（systemd）

```bash
# サービスの有効化と起動
ensure_service() {
    local svc="$1"
    systemctl is-enabled --quiet "$svc" || sudo systemctl enable "$svc"
    systemctl is-active --quiet "$svc" || sudo systemctl start "$svc"
}
```

## エラーハンドリングと安全性

### 基本設定

```bash
#!/bin/bash
set -euo pipefail
# -e: エラーで即座に終了
# -u: 未定義変数でエラー
# -o pipefail: パイプライン内のエラーを検知
```

### クリーンアップと排他制御

```bash
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

## 確認コマンド一覧

| リソース | 確認コマンド | 用途 |
|---------|------------|------|
| **ファイルシステム** |
| ディレクトリ | `[ -d "$path" ]` | ディレクトリの存在確認 |
| ファイル | `[ -f "$path" ]` | 通常ファイルの存在確認 |
| 任意のファイル | `[ -e "$path" ]` | 任意のファイルタイプの存在確認 |
| シンボリックリンク | `[ -L "$path" ]` | シンボリックリンクの確認 |
| **パッケージ** |
| Debian/Ubuntu | `dpkg -l "$pkg" &>/dev/null` | aptパッケージの確認 |
| Arch Linux | `pacman -Qi "$pkg" &>/dev/null` | pacmanパッケージの確認 |
| RHEL/CentOS | `rpm -q "$pkg" &>/dev/null` | yumパッケージの確認 |
| **システム** |
| コマンド | `command -v "$cmd" &>/dev/null` | コマンドの存在確認 |
| サービス（有効） | `systemctl is-enabled --quiet "$svc"` | 自動起動設定の確認 |
| サービス（実行中） | `systemctl is-active --quiet "$svc"` | サービス実行状態の確認 |
| ユーザー | `id -u "$user" &>/dev/null` | ユーザーの存在確認 |
| グループ | `getent group "$grp" &>/dev/null` | グループの存在確認 |

## 実例：Before/After

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

## チェックリスト

- [ ] `mkdir` → `mkdir -p` に変更
- [ ] `ln -s` → `ln -sfn` に変更
- [ ] `cp` → `cp -af` でシンプルに
- [ ] `rm` → `rm -f` / `rm -rf` でエラー抑制
- [ ] ファイル追記前に `grep` で重複確認
- [ ] `sed -i` は条件付きで使用（必要な場合のみ）
- [ ] パッケージマネージャーの冪等性を活用
- [ ] スクリプト冒頭に `set -euo pipefail`
- [ ] 必要に応じて `trap` でクリーンアップ

## 冪等性の原則

1. **確認してから実行**：現在の状態をチェックしてから変更
2. **差分のみ適用**：必要な変更だけを実行
3. **エラーを適切に処理**：既に完了している操作は `|| true` で無視
4. **アトミックに操作**：中途半端な状態を避ける

冪等性により「何度実行しても安全」が保証され、信頼性の高い自動化を実現できます。