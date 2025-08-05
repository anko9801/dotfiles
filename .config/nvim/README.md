# Neovim 設定

lazy.nvim を使用したモダンな Neovim 設定です。

## プラグインマネージャー

### lazy.nvim

初回起動時に自動でインストールされます。手動インストールは不要です。

```lua
-- init.lua で自動ブートストラップ
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  -- 自動インストール処理
end
```

## ディレクトリ構成

```
~/.config/nvim/
├── init.lua                    # メイン設定（lazy.nvim のブートストラップ）
└── lua/
    ├── config/
    │   ├── options.lua         # 基本オプション
    │   ├── keymaps.lua         # キーマッピング
    │   └── autocmds.lua        # 自動コマンド
    └── plugins/
        ├── colorscheme.lua     # カラースキーム
        ├── ui.lua              # UI拡張
        ├── editor.lua          # エディタ機能
        ├── terminal.lua        # ターミナル統合
        └── coding.lua          # コーディング支援
```

## 主なプラグイン

### UI・エディタ
- **nvim-tree**: ファイルエクスプローラー（`<leader>e`）
- **telescope.nvim**: ファジーファインダー
- **bufferline.nvim**: バッファタブライン
- **lualine.nvim**: ステータスライン

### コーディング支援
- **nvim-treesitter**: 高度なシンタックスハイライト
- **nvim-lspconfig**: Language Server Protocol
- **nvim-cmp**: 自動補完
- **gitsigns.nvim**: Git 統合

### ターミナル
- **toggleterm.nvim**: ターミナル統合

## キーマップ

- リーダーキー: `<Space>`
- ファイルエクスプローラー: `<leader>e`
- その他は `lua/config/keymaps.lua` を参照

## プラグインの追加方法

`lua/plugins/` ディレクトリに新しい Lua ファイルを作成：

```lua
-- lua/plugins/example.lua
return {
  "author/plugin-name",
  config = function()
    -- 設定
  end,
}
```

## 設定の更新

設定変更後、Neovim を再起動するか `:Lazy sync` を実行してプラグインを同期。