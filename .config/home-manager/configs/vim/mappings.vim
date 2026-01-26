" =============================================================================
" Vim Key Mappings
" =============================================================================

" =============================================================================
" Normal Mode
" =============================================================================

" Better navigation
nnoremap j gj
nnoremap k gk
vnoremap j gj
vnoremap k gk
nnoremap <Down> gj
nnoremap <Up> gk

" Window navigation
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Window resize
nnoremap <C-w>+ :resize +5<CR>
nnoremap <C-w>- :resize -5<CR>
nnoremap <C-w>> :vertical resize +5<CR>
nnoremap <C-w>< :vertical resize -5<CR>

" Tab navigation
nnoremap <Leader>tn :tabnew<CR>
nnoremap <Leader>tc :tabclose<CR>
nnoremap <Leader>to :tabonly<CR>
nnoremap <Leader>tm :tabmove<Space>
nnoremap ]t :tabnext<CR>
nnoremap [t :tabprevious<CR>
nnoremap <Leader>1 1gt
nnoremap <Leader>2 2gt
nnoremap <Leader>3 3gt
nnoremap <Leader>4 4gt
nnoremap <Leader>5 5gt

" Buffer navigation
nnoremap ]b :bnext<CR>
nnoremap [b :bprevious<CR>
nnoremap <Leader>bd :bdelete<CR>
nnoremap <Leader>bD :bdelete!<CR>

" Quick save/quit
nnoremap <Leader>w :w<CR>
nnoremap <Leader>q :q<CR>
nnoremap <Leader>Q :qa!<CR>

" Clear search highlight
nnoremap <silent> <Esc><Esc> :nohlsearch<CR>
nnoremap <silent> <Leader>/ :nohlsearch<CR>

" Toggle settings
nnoremap <Leader>tn :set number!<CR>
nnoremap <Leader>tr :set relativenumber!<CR>
nnoremap <Leader>tw :set wrap!<CR>
nnoremap <Leader>tp :set paste!<CR>

" Quick edit vimrc
nnoremap <Leader>ev :edit $MYVIMRC<CR>
nnoremap <Leader>sv :source $MYVIMRC<CR>

" Yank to end of line
nnoremap Y y$

" Paste without moving cursor (from backup)
nnoremap p gP

" Quick access to visual block mode
nnoremap gv <C-v>

" Keep cursor centered
nnoremap n nzzzv
nnoremap N Nzzzv
nnoremap J mzJ`z

" Undo break points
inoremap , ,<C-g>u
inoremap . .<C-g>u
inoremap ! !<C-g>u
inoremap ? ?<C-g>u

" =============================================================================
" Visual Mode
" =============================================================================

" Stay in visual mode after indenting
vnoremap < <gv
vnoremap > >gv

" Move selected lines
vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv

" Better paste
vnoremap p "_dP

" Search for selected text
vnoremap // y/\V<C-R>=escape(@",'/\')<CR><CR>

" =============================================================================
" Insert Mode
" =============================================================================

" Quick escape
inoremap jk <Esc>
inoremap kj <Esc>

" Move cursor in insert mode
inoremap <C-h> <Left>
inoremap <C-j> <Down>
inoremap <C-k> <Up>
inoremap <C-l> <Right>

" Delete word
inoremap <C-w> <C-o>dw
inoremap <C-u> <C-o>d0

" =============================================================================
" Command Mode
" =============================================================================

" Command line navigation
cnoremap <C-a> <Home>
cnoremap <C-e> <End>
cnoremap <C-p> <Up>
cnoremap <C-n> <Down>
cnoremap <C-b> <Left>
cnoremap <C-f> <Right>
cnoremap <M-b> <S-Left>
cnoremap <M-f> <S-Right>

" Expand current directory
cnoremap %% <C-R>=fnameescape(expand('%:h')).'/'<CR>

" =============================================================================
" Terminal Mode (Vim 8+)
" =============================================================================
if has('terminal')
  tnoremap <Esc><Esc> <C-\><C-n>
  tnoremap <C-w>h <C-\><C-n><C-w>h
  tnoremap <C-w>j <C-\><C-n><C-w>j
  tnoremap <C-w>k <C-\><C-n><C-w>k
  tnoremap <C-w>l <C-\><C-n><C-w>l
endif

" =============================================================================
" Quick Fix
" =============================================================================
nnoremap <Leader>co :copen<CR>
nnoremap <Leader>cc :cclose<CR>
nnoremap ]q :cnext<CR>
nnoremap [q :cprevious<CR>

" =============================================================================
" Functions and Commands
" =============================================================================

" Strip trailing whitespace
function! StripTrailingWhitespace()
  let save_cursor = getpos(".")
  let old_query = getreg('/')
  :%s/\s\+$//e
  call setpos('.', save_cursor)
  call setreg('/', old_query)
endfunction
nnoremap <Leader>sw :call StripTrailingWhitespace()<CR>

" Toggle between number and relativenumber
function! ToggleNumber()
  if(&relativenumber == 1)
    set norelativenumber
    set number
  else
    set relativenumber
  endif
endfunction
nnoremap <Leader>tn :call ToggleNumber()<CR>

" Create directory if it doesn't exist
function! s:MkNonExDir(file, buf)
  if empty(getbufvar(a:buf, '&buftype')) && a:file!~#'\v^\w+\:\/'
    let dir=fnamemodify(a:file, ':h')
    if !isdirectory(dir)
      call mkdir(dir, 'p')
    endif
  endif
endfunction
augroup BWCCreateDir
  autocmd!
  autocmd BufWritePre * :call s:MkNonExDir(expand('<afile>'), +expand('<abuf>'))
augroup END

" =============================================================================
" WSL Specific Mappings
" =============================================================================
if system('uname -a | grep -i microsoft') != ''
  " WSL clipboard copy
  nmap <silent> <C-c> <Plug>WslCopy
  xmap <silent> <C-c> <Plug>WslCopy
endif