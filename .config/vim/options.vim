" =============================================================================
" Vim Options Configuration
" =============================================================================

" Leader key
let mapleader = "\<Space>"
let g:mapleader = "\<Space>"

" =============================================================================
" Display
" =============================================================================
set title                      " ウィンドウタイトルを設定
set number                     " 行番号を表示
set relativenumber            " 相対行番号を表示
set cursorline                " カーソル行をハイライト
set cursorcolumn              " カーソル列をハイライト
set showmatch                 " 対応する括弧をハイライト
set matchtime=1               " 括弧のハイライト時間
set list                      " 不可視文字を表示
set listchars=tab:▸\ ,trail:·,extends:>,precedes:<,nbsp:+
set wrap                      " 長い行を折り返す
set linebreak                 " 単語の途中で折り返さない
set showbreak=↪               " 折り返し行の先頭に表示
set display=lastline          " 長い行を省略しない

" =============================================================================
" Editor
" =============================================================================
set expandtab                 " タブをスペースに展開
set tabstop=2                 " タブ幅
set shiftwidth=2              " インデント幅
set softtabstop=2             " 編集時のタブ幅
set autoindent                " 自動インデント
set smartindent               " スマートインデント
set backspace=indent,eol,start " バックスペースの挙動
set virtualedit=block         " 矩形選択時に文字がなくても選択可能

" =============================================================================
" Search
" =============================================================================
set ignorecase                " 検索時に大文字小文字を区別しない
set smartcase                 " 大文字が含まれる場合は区別する
set incsearch                 " インクリメンタルサーチ
set hlsearch                  " 検索結果をハイライト
set wrapscan                  " 検索時にファイルの最後まで行ったら最初に戻る

" =============================================================================
" Completion
" =============================================================================
set wildmenu                  " コマンドライン補完を有効
set wildmode=list:longest,full " 補完の動作
set wildignore=*.o,*~,*.pyc,*.class " 補完で無視するファイル
set wildignore+=*/.git/*,*/.hg/*,*/.svn/*,*/.DS_Store
set completeopt=menuone,noselect,noinsert " 補完メニューの動作
set pumheight=10              " 補完メニューの高さ

" =============================================================================
" Files
" =============================================================================
set hidden                    " バッファを切り替えても変更を保持
set autoread                  " 外部で変更されたら自動で読み込む
set nobackup                  " バックアップファイルを作成しない
set nowritebackup            " 書き込み時のバックアップを作成しない
set updatetime=300            " スワップファイルの更新時間
set shortmess+=c              " 補完メッセージを短縮

" =============================================================================
" UI
" =============================================================================
set splitbelow                " 新しいウィンドウを下に開く
set splitright                " 新しいウィンドウを右に開く
set laststatus=2              " ステータスラインを常に表示
set showcmd                   " コマンドを表示
set ruler                     " カーソル位置を表示
set noshowmode                " モードを表示しない（airline使用時）
set signcolumn=yes            " サインカラムを常に表示
set scrolloff=5               " スクロール時の余白
set sidescrolloff=5           " 横スクロール時の余白

" =============================================================================
" Performance
" =============================================================================
set lazyredraw                " マクロ実行中は画面を更新しない
set ttyfast                   " 高速ターミナル接続
set synmaxcol=200             " シンタックスハイライトの最大列数
set regexpengine=1            " 正規表現エンジン

" =============================================================================
" Sound
" =============================================================================
set noerrorbells              " エラー音を鳴らさない
set novisualbell              " ビジュアルベルを無効
set t_vb=                     " ビープ音を無効
set belloff=all               " 全てのベル音を無効

" =============================================================================
" Encoding
" =============================================================================
set encoding=utf-8
set fileencoding=utf-8
set fileencodings=utf-8,iso-2022-jp,euc-jp,sjis,cp932
set fileformats=unix,dos,mac

" =============================================================================
" Misc
" =============================================================================
set history=10000             " コマンド履歴の保存数
set mouse=a                   " マウスを有効
if !has('nvim')
  set ttymouse=xterm2         " ターミナルでのマウス
endif
set viminfo='100,<1000,s100,h " ヤンクの制限をゆるくする
set tags=./tags;,tags;        " タグファイルの検索パス
set ambiwidth=double          " □や○文字が崩れる問題を解決

" Persistent undo
if has('persistent_undo')
  set undofile
endif

" True color support
if has('termguicolors')
  set termguicolors
  let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
  let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
endif

" Clipboard
if has('clipboard')
  if has('unnamedplus')
    set clipboard=unnamedplus,unnamed
  else
    set clipboard=unnamed
  endif
endif