syntax on

set ignorecase
set smartcase
set incsearch
set hlsearch
set shiftround
set infercase
set virtualedit=all
set hidden
set switchbuf=useopen
set showmatch
set matchtime=3
set noexpandtab tabstop=4 softtabstop=4 shiftwidth=4
set matchpairs& matchpairs+=<:>
set backspace=indent,eol,start
set nowritebackup
set nobackup
set noswapfile
set number
set wrap
set textwidth=0
set t_vb=
set novisualbell
set tags=./tags;
set list
set listchars=tab:>-,trail:-,extends:>,precedes:<,nbsp:%
set rtp+=~/.fzf
set mouse=a
set scrolloff=4
set gdefault
set vb t_vb=
set completeopt=noinsert
set textwidth=100

nnoremap j gj
nnoremap k gk
vnoremap j gj
vnoremap k gk
nnoremap p gP

nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l
nnoremap <C-h> :vsp<CR> :exe("tjump ".expand('<cword>'))<CR>
nnoremap <C-k> :split<CR> :exe("tjump ".expand('<cword>'))<CR>

nnoremap gv <C-v>

nmap <silent> <C-c> <Plug>WslCopy
xmap <silent> <C-c> <Plug>WslCopy

nnoremap s nop
nnoremap sh <C-w>h
nnoremap sj <C-w>j
nnoremap sk <C-w>k
nnoremap sl <C-w>l
nnoremap sH <C-w>H
nnoremap sJ <C-w>J
nnoremap sK <C-w>K
nnoremap sL <C-w>L
nnoremap ss <C-w>s
nnoremap sv <C-w>v
nnoremap sg nop
nnoremap sgv :vsp<CR> :exe("tjump ".expand('<cword>'))<CR>
nnoremap sgs :split<CR> :exe("tjump ".expand('<cword>'))<CR>
nnoremap <F3> :noh<CR>
nnoremap <F4> :source ~/.vimrc<CR>
nnoremap <F2> "*p

inoremap jj <Esc>
