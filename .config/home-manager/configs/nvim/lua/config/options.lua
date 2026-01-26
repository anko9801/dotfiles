-- Neovim Options
local opt = vim.opt

-- UI
opt.number = true         -- 行番号表示
opt.relativenumber = true -- 相対行番号
opt.termguicolors = true  -- True color support
opt.signcolumn = "yes"    -- サインカラムを常に表示
opt.cursorline = true     -- カーソル行をハイライト
opt.list = true           -- 不可視文字を表示
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- Editor
opt.expandtab = true      -- タブをスペースに変換
opt.shiftwidth = 2        -- インデント幅
opt.tabstop = 2           -- タブ幅
opt.smartindent = true    -- スマートインデント
opt.wrap = false          -- 行の折り返しを無効

-- Search
opt.ignorecase = true     -- 大文字小文字を無視
opt.smartcase = true      -- 大文字が含まれる場合は区別
opt.hlsearch = true       -- 検索結果をハイライト
opt.incsearch = true      -- インクリメンタルサーチ

-- System
opt.clipboard = "unnamedplus" -- システムクリップボード連携
opt.mouse = "a"               -- マウスサポート
opt.undofile = true           -- 永続的なundo
opt.updatetime = 250          -- 更新時間
opt.timeoutlen = 300          -- キーマップのタイムアウト

-- Split
opt.splitbelow = true     -- 水平分割を下に
opt.splitright = true     -- 垂直分割を右に

-- Completion
opt.completeopt = "menuone,noselect,noinsert"
opt.pumheight = 10        -- ポップアップメニューの高さ

-- Fold
opt.foldmethod = "expr"
opt.foldexpr = "nvim_treesitter#foldexpr()"
opt.foldenable = false    -- 起動時は折りたたまない