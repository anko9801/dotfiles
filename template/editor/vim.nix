# baseModule: vim editor
{ pkgs, ... }:
{
  programs.vim = {
    enable = true;

    settings = {
      number = true;
      relativenumber = true;
      tabstop = 2;
      shiftwidth = 2;
      expandtab = true;
      ignorecase = true;
      smartcase = true;
      mouse = "a";
      background = "dark";
    };

    extraConfig = ''
      set nocompatible
      set encoding=utf-8
      set cursorline
      set wildmenu
      set wildmode=list:longest,full
      set smartindent
      set autoindent
      set hidden
      set autoread
      set noswapfile
      set undofile
      set undodir=~/.local/state/vim/undo

      if has('termguicolors')
        set termguicolors
      endif

      syntax enable
      colorscheme desert

      let mapleader = " "

      nnoremap j gj
      nnoremap k gk
      nnoremap <C-h> <C-w>h
      nnoremap <C-j> <C-w>j
      nnoremap <C-k> <C-w>k
      nnoremap <C-l> <C-w>l
      nnoremap <silent> <Esc><Esc> :nohlsearch<CR>
      vnoremap < <gv
      vnoremap > >gv
      inoremap jk <Esc>
      nnoremap <leader>w :w<CR>
      nnoremap <leader>q :q<CR>

      if !isdirectory(expand('~/.local/state/vim/undo'))
        call mkdir(expand('~/.local/state/vim/undo'), 'p')
      endif
    '';

    plugins = with pkgs.vimPlugins; [
      vim-sensible
      vim-commentary
      vim-surround
    ];
  };
}
