# Vim — lightweight editor
_:

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
      set encoding=utf-8
      set smartindent
      set autoindent
      set cursorline
      set scrolloff=8
      set undofile
      set noswapfile
      set nobackup

      if has('clipboard')
        set clipboard=unnamedplus
      endif

      syntax enable
    '';
  };
}
