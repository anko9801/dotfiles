augroup MyAutoCmd
  autocmd!
augroup END
augroup EditVim
  autocmd!
  autocmd BufWritePost .vimrc source $MYVIMRC
  autocmd FileType vim setlocal foldmethod=marker
augroup END

syntax on

let mapleader="-"
let g:mapleader="-"

au BufRead,BufNewFile *.ui set filetype=xml

autocmd FileType javascript setl expandtab tabstop=2 shiftwidth=2 softtabstop=2
autocmd FileType typescript setl expandtab tabstop=2 shiftwidth=2 softtabstop=2
autocmd FileType html setl expandtab tabstop=2 shiftwidth=2 softtabstop=2
autocmd FileType css setl expandtab tabstop=2 shiftwidth=2 softtabstop=2
autocmd FileType python setl autoindent
autocmd FileType python setl smartindent cinwords=if,elif,else,for,while,try,except,finally,def,class
autocmd FileType python setl noexpandtab tabstop=4 shiftwidth=4 softtabstop=4
autocmd FileType xml setl expandtab tabstop=1 shiftwidth=1 softtabstop=1
"autocmd FileType cpp setl expandtab tabstop=4 shiftwidth=4 softtabstop=4

autocmd FileType qf setlocal wrap


"dein Scripts-----------------------------
if &compatible
  set nocompatible
endif

" Required:
set runtimepath+=$HOME/.cache/dein/repos/github.com/Shougo/dein.vim

" Required:
if dein#load_state($HOME . '/.config/dein')

  " XDG base direcory compartible
  let g:dein#cache_directory = $HOME . '/.cache/dein'

  " dein begin
  call dein#begin($HOME . '/.config/dein')

 " プラグインリストを収めた TOML ファイル
 " 予め TOML ファイル（後述）を用意しておく
 let s:toml_dir  = $HOME . '/.vim'
 let s:toml      = s:toml_dir . '/dein.toml'
 let s:lazy_toml = s:toml_dir . '/dein_lazy.toml'

 " TOML を読み込み、キャッシュしておく
 call dein#load_toml(s:toml,      {'lazy': 0})
 call dein#load_toml(s:lazy_toml, {'lazy': 1})

  " Required:
  call dein#end()
  call dein#save_state()
endif

" Required:
filetype plugin indent on

" If you want to install not installed plugins on startup.
if dein#check_install()
  call dein#install()
endif

"End dein Scripts-------------------------

source ~/.vim/wsl-copy.vim

" 簡易的な設定は以下をコピペ
syntax enable
set background=dark
" set termguicolors
colorscheme gruvbox

" 文字コード
set encoding=utf-8
scriptencoding utf-8
set fileencoding=utf-8       " 保存時の文字コード
set fileencodings=ucs-boms,utf-8,euc-jp,cp932 " 読み込み時の文字コードの自動判別. 左側が優先される
set fileformats=unix,dos,mac " 改行コードの自動判別. 左側が優先される
set ambiwidth=double         " □や○文字が崩れる問題を解決

" バックアップ
set nobackup          " バックアップファイルを作らない
set noswapfile        " スワップファイルを作らない
set nowritebackup
set autoread          " 編集中のファイルが変更されたら自動で読み直す
set hidden            " バッファが編集中でもその他のファイルを開けるように
set showcmd           " 入力中のコマンドをステータスに表示する
set switchbuf=useopen " バッファを開くときは既に開かれているものを再利用
" -V20/tmp/vim.log

" 表示
set number  " 行番号を表示
set relativenumber " 相対行番号を表示
set wrap
set textwidth=0

" Tab
set tabstop=4     " 画面上でタブ文字が占める幅
set softtabstop=4 " 連続した空白に対してタブキーやバックスペースキーでカーソルが動く幅
set autoindent    " 改行時に前の行のインデントを継続する
set smartindent   " 改行時に前の行の構文をチェックし次の行のインデントを増減する
set shiftwidth=4  " smartindentで増減する幅
set list listchars=tab:>-,trail:-,extends:>,precedes:<,nbsp:%  " 不可視文字を可視化(タブが「▸-」と表示される)
"set expandtab tabstop=4 softtabstop=4 shiftwidth=4 " Tab文字を半角スペースにする
set infercase

" 文字列検索
set incsearch  " インクリメンタルサーチ. １文字入力毎に検索を行う
set ignorecase " 検索パターンに大文字小文字を区別しない
set smartcase  " 検索パターンに大文字を含んでいたら大文字小文字を区別する
set hlsearch   " 検索結果をハイライト
nmap <silent> <Esc><Esc> :nohlsearch<CR>

" ベル音
set t_vb=
set novisualbell
set belloff=all

" キー入力
set virtualedit=all             " hjklで自由に移動できる
set backspace=indent,eol,start  " バックスペースキーの有効化
set viminfo='100,<1000,s100,h   " ヤンクの制限をゆるくする
set showmatch matchtime=3       " 括弧の対応関係を一瞬表示する
set matchpairs& matchpairs+=<:> " < >のペアを追加する

" コマンド
set wildmenu " コマンドモードの補完
set history=5000 " 保存するコマンド履歴の数
set tags=./tags;
set rtp+=~/.fzf

if system('uname -a | grep icrosoft') != ''
  augroup myYank
    autocmd!
    autocmd TextYankPost * :call system('clip.exe', @")
  augroup END
endif

hi Pmenu ctermbg=8
hi PmenuSel ctermbg=1
hi PmenuSbar ctermbg=0

cnoremap <expr> / getcmdtype() == '/' ? '\/' : '/'
cnoremap <expr> ? getcmdtype() == '?' ? '\?' : '?'

nnoremap j gj
nnoremap k gk

nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l
nnoremap ss :split<CR>
nnoremap sv :vsp<CR>

inoremap jj <Esc>
map <silent> <leader>e :NERDTreeToggle<cr>
map <silent> <leader>f :TagbarToggle<cr>
map <silent> <leader>0 :set fdm=marker fmr={,} foldlevel=0<cr>
map <silent> <leader>1 :set fdm=marker fmr={,} foldlevel=1<cr>
map <silent> <leader>2 :set fdm=marker fmr={,} foldlevel=2<cr>
map <silent> <leader>3 :set fdm=marker fmr={,} foldlevel=3<cr>

retab 4
retab!

filetype plugin on

if has('persistent_undo')
    set undodir=~/.vim/undo
    set undofile
endif

