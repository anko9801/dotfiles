{ pkgs, ... }:

{
  programs.vim = {
    enable = true;

    settings = {
      # Line numbers
      number = true;
      relativenumber = true;

      # Tabs and indentation
      tabstop = 2;
      shiftwidth = 2;
      expandtab = true;

      # Search
      ignorecase = true;
      smartcase = true;

      # UI
      mouse = "a";
      background = "dark";
    };

    extraConfig = ''
      " =============================================================================
      " Basic Settings
      " =============================================================================
      set nocompatible
      set encoding=utf-8
      set fileencoding=utf-8
      set fileencodings=utf-8,iso-2022-jp,euc-jp,sjis
      set fileformats=unix,dos,mac

      " UI
      set cursorline
      set showmatch
      set wildmenu
      set wildmode=list:longest,full
      set pumheight=10
      set laststatus=2
      set showcmd
      set ruler
      set signcolumn=yes
      set scrolloff=8
      set sidescrolloff=8
      set list
      set listchars=tab:>-,trail:-,extends:>,precedes:<,nbsp:%

      " Editor
      set smartindent
      set autoindent
      set backspace=indent,eol,start
      set hidden
      set wrap
      set linebreak

      " Files
      set autoread
      set nobackup
      set noswapfile
      set undofile
      set undodir=~/.local/state/vim/undo

      " Performance
      set updatetime=300
      set timeoutlen=500
      set lazyredraw
      set ttyfast

      " Clipboard
      if has('clipboard')
        set clipboard=unnamedplus
      endif

      " True color
      if has('termguicolors')
        set termguicolors
      endif

      " Syntax and colors
      syntax enable
      colorscheme desert

      " =============================================================================
      " Leader Key
      " =============================================================================
      let mapleader = " "
      let g:mapleader = " "

      " =============================================================================
      " Key Mappings
      " =============================================================================
      " Better j/k navigation (wrapped lines)
      nnoremap j gj
      nnoremap k gk
      vnoremap j gj
      vnoremap k gk

      " Window navigation
      nnoremap <C-h> <C-w>h
      nnoremap <C-j> <C-w>j
      nnoremap <C-k> <C-w>k
      nnoremap <C-l> <C-w>l

      " Window resize
      nnoremap <C-Up> :resize -2<CR>
      nnoremap <C-Down> :resize +2<CR>
      nnoremap <C-Left> :vertical resize -2<CR>
      nnoremap <C-Right> :vertical resize +2<CR>

      " Clear search highlight
      nnoremap <silent> <Esc><Esc> :nohlsearch<CR>

      " Better indenting
      vnoremap < <gv
      vnoremap > >gv

      " Move lines
      nnoremap <A-j> :m .+1<CR>==
      nnoremap <A-k> :m .-2<CR>==
      vnoremap <A-j> :m '>+1<CR>gv=gv
      vnoremap <A-k> :m '<-2<CR>gv=gv

      " Yank to end of line
      nnoremap Y y$

      " Keep cursor centered
      nnoremap n nzzzv
      nnoremap N Nzzzv
      nnoremap J mzJ`z

      " Quick escape
      inoremap jk <Esc>

      " Buffer navigation
      nnoremap <S-h> :bprevious<CR>
      nnoremap <S-l> :bnext<CR>

      " Save and quit
      nnoremap <leader>w :w<CR>
      nnoremap <leader>q :q<CR>
      nnoremap <leader>Q :qa!<CR>

      " Split windows
      nnoremap <leader>sv <C-w>v
      nnoremap <leader>sh <C-w>s
      nnoremap <leader>se <C-w>=
      nnoremap <leader>sx :close<CR>

      " QuickFix
      nnoremap ]q :cnext<CR>zz
      nnoremap [q :cprevious<CR>zz
      nnoremap <leader>co :copen<CR>
      nnoremap <leader>cc :cclose<CR>

      " Command-line navigation
      cnoremap <C-a> <Home>
      cnoremap <C-e> <End>
      cnoremap <C-b> <Left>
      cnoremap <C-f> <Right>

      " Terminal mode
      if has('terminal')
        tnoremap <Esc><Esc> <C-\><C-n>
      endif

      " =============================================================================
      " Autocommands
      " =============================================================================
      augroup vimrc
        autocmd!
        " Remove trailing whitespace on save
        autocmd BufWritePre * :%s/\s\+$//e
        " Restore cursor position
        autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
        " Close some filetypes with q
        autocmd FileType help,qf,man nnoremap <buffer> q :close<CR>
      augroup END

      " =============================================================================
      " WSL Clipboard Integration
      " =============================================================================
      if system('uname -a | grep -i microsoft') != '''
        augroup WslYank
          autocmd!
          autocmd TextYankPost * if v:event.operator ==# 'y' | call system('clip.exe', @") | endif
        augroup END
      endif

      " =============================================================================
      " Create directories
      " =============================================================================
      if !isdirectory(expand('~/.local/state/vim/undo'))
        call mkdir(expand('~/.local/state/vim/undo'), 'p')
      endif
    '';

    plugins = with pkgs.vimPlugins; [
      # Minimal plugins for server use
      vim-sensible
      vim-commentary
      vim-surround
      vim-fugitive
    ];
  };
}
