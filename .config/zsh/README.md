# Zsh Configuration

宣言的でモジュラーな Zsh 設定。

## 特徴

- **最小限の .zshrc** - たった12行の宣言的な設定
- **Sheldon によるプラグイン管理** - 高速で信頼性の高いプラグインマネージャー
- **モジュラー設計** - 機能ごとに分離されたプラグインファイル
- **遅延読み込み** - zsh-defer による起動時間の最適化

## 構成

```
.config/zsh/
├── .zshrc                    # メインの設定ファイル（最小限）
├── README.md                 # このファイル
├── plugins/                  # モジュラープラグイン
│   ├── env.zsh              # 環境変数とPATH設定
│   ├── history.zsh          # 履歴設定
│   ├── options.zsh          # シェルオプション
│   ├── completion.zsh       # 補完システム設定
│   ├── abbr.zsh            # 略語定義（zsh-abbr）
│   ├── functions.zsh        # カスタム関数
│   ├── fzf-tab.zsh         # FZFタブ補完設定
│   ├── prompt.zsh          # フォールバックプロンプト
│   └── local.zsh           # マシン固有の設定
├── abbr.zsh                 # 旧略語定義（互換性のため残存）
└── functions.zsh            # 旧カスタム関数（互換性のため残存）
```

## Sheldon

[Sheldon](https://github.com/rossmacarthur/sheldon) は Rust 製の高速なシェルプラグインマネージャーです。

### なぜ Sheldon？

- **高速** - Rust 製で起動が速い
- **シンプル** - TOML ベースの設定
- **柔軟** - テンプレート機能で複雑な読み込み制御が可能
- **信頼性** - 依存関係の解決が確実

### プラグイン設定

プラグインは `.config/sheldon/plugins.toml` で管理されています：

```toml
# GitHub からプラグインをインストール
[plugins.zsh-syntax-highlighting]
github = "zsh-users/zsh-syntax-highlighting"
apply = ["defer"]  # 遅延読み込み

# ローカルプラグイン
[plugins.env]
local = "~/.config/zsh/plugins"
use = ["env.zsh"]

# インラインコマンド
[plugins.starship]
inline = 'command -v starship &>/dev/null && eval "$(starship init zsh)"'
```

## 主な機能

### 環境変数管理（env.zsh）

- XDG Base Directory 準拠
- 動的 PATH 構築
- ツール固有の環境変数

### 補完システム（completion.zsh）

- メニュー選択
- カラー表示
- キャッシュ機能
- コンテキスト対応補完

### 略語システム（abbr.zsh）

zsh-abbr による展開可能な略語：

- `g` → `git`
- `ls` → `eza`（インストール済みの場合）
- `gqcd` → `cd $(ghq list --full-path | fzf)`

### カスタム関数（functions.zsh）

- `ghq-fzf` - リポジトリを FZF で選択して移動
- `mkcd` - ディレクトリ作成して移動
- `extract` - 各種アーカイブの展開
- `fcd` - FZF でディレクトリ選択
- `fbr` - Git ブランチ切り替え

## カスタマイズ

### マシン固有の設定

`~/.config/zsh/plugins/local.zsh` または `~/.zshrc.local` に記述：

```zsh
# 例：会社のプロキシ設定
export http_proxy="http://proxy.company.com:8080"

# 例：個人的なエイリアス
alias work="cd ~/work"
```

### プラグインの追加

`.config/sheldon/plugins.toml` を編集：

```toml
[plugins.my-plugin]
github = "user/repo"
apply = ["defer"]
```

## トラブルシューティング

### Sheldon がインストールされていない

```bash
brew install sheldon  # macOS
cargo install sheldon  # Rust経由
```

### プラグインの更新

```bash
sheldon lock --update
```

### キャッシュのクリア

```bash
rm -rf ~/.cache/sheldon
```