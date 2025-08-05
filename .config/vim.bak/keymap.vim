

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

autocmd FileType javascript setl expandtab tabstop=4 shiftwidth=4 softtabstop=4
autocmd FileType typescript setl expandtab tabstop=2 shiftwidth=2 softtabstop=2
autocmd FileType html setl expandtab tabstop=2 shiftwidth=2 softtabstop=2
autocmd FileType css setl expandtab tabstop=2 shiftwidth=2 softtabstop=2
autocmd FileType python setl autoindent
autocmd FileType python setl smartindent cinwords=if,elif,else,for,while,try,except,finally,def,class
autocmd FileType python setl noexpandtab tabstop=4 shiftwidth=4 softtabstop=4
autocmd FileType xml setl expandtab tabstop=1 shiftwidth=1 softtabstop=1
"autocmd FileType cpp setl expandtab tabstop=4 shiftwidth=4 softtabstop=4
autocmd VimEnter * RainbowParenthesesToggle
autocmd Syntax * RainbowParenthesesLoadRound
autocmd Syntax * RainbowParenthesesLoadSquare
autocmd Syntax * RainbowParenthesesLoadBraces

" 検索系
" 大文字/小文字を無視
set ignorecase
" 大文字を打ったらcase insensitive
set smartcase
" 入力途中もマッチした場所へ移動
set incsearch
" 検索した文字をハイライトする
set hlsearch
" インデントをshiftwidthの倍数になるようにする
" set shiftround
" インデント時
set noexpandtab tabstop=4 softtabstop=4 shiftwidth=4
set infercase
" hjklで自由に移動できる
set virtualedit=all
" set virtualedit=onemore
" バッファを保存せずに移動できる
set hidden
" バッファを開くときは既に開かれているものを再利用



jj


