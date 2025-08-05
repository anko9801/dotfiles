# Vim 設定

XDG Base Directory に対応した Vim 設定です。プラグインマネージャーは使用せず、シンプルな構成になっています。

## ディレクトリ構成

```
~/.config/vim/
├── vimrc          # メイン設定ファイル
├── options.vim    # 基本オプション
├── mappings.vim   # キーマッピング
├── autocmds.vim   # 自動コマンド
└── lsp.vim        # LSP設定（未使用）
```

## XDG Base Directory 対応

vimrc 内で以下のディレクトリを自動設定：
- 設定: `$XDG_CONFIG_HOME/vim/`
- データ: `$XDG_DATA_HOME/vim/`
- 状態: `$XDG_STATE_HOME/vim/`（undo, backup, swap, view）
- キャッシュ: `$XDG_CACHE_HOME/vim/`

環境変数の設定：
```bash
# ~/.bashrc または ~/.zshrc
export VIMINIT='let $MYVIMRC="$XDG_CONFIG_HOME/vim/vimrc" | source $MYVIMRC'
```

## 主な設定

### 基本設定
- UTF-8 エンコーディング
- 行番号・相対行番号表示
- タブ幅 2、スペースに展開
- インクリメンタル検索、大文字小文字を賢く判定
- マウスサポート
- クリップボード統合

### ファイル管理
- undo ファイル保持
- バックアップ・スワップファイル有効
- 隠しバッファ許可
- 自動読み込み

### カラースキーム
- iceberg（フォールバック: desert）
- True color サポート

## モジュール構成

実際の設定は以下のファイルに分割されています：
- `options.vim`: エディタの基本設定
- `mappings.vim`: キーバインディング
- `autocmds.vim`: 自動コマンド（末尾空白削除、カーソル位置復元など）

## プラグインについて

現在の設定ではプラグインマネージャーを使用していません。将来的に dpp.vim への移行を検討中です。