_:

{
  programs.nixvim = {
    # Global options
    opts = {
      # Line numbers
      number = true;
      relativenumber = true;

      # Tabs and indentation
      tabstop = 2;
      shiftwidth = 2;
      expandtab = true;
      smartindent = true;

      # Search
      ignorecase = true;
      smartcase = true;
      hlsearch = true;
      incsearch = true;

      # UI
      termguicolors = true;
      signcolumn = "yes";
      cursorline = true;
      scrolloff = 8;
      sidescrolloff = 8;
      list = true;
      listchars = {
        tab = "» ";
        trail = "·";
        nbsp = "␣";
      };

      # Behavior
      hidden = true;
      wrap = false;
      swapfile = false;
      backup = false;
      undofile = true;
      updatetime = 250;
      timeoutlen = 300;

      # Split
      splitbelow = true;
      splitright = true;

      # Clipboard
      clipboard = "unnamedplus";

      # Mouse
      mouse = "a";

      # Completion
      completeopt = "menuone,noselect,noinsert";
      pumheight = 10;

      # Fold (native treesitter - Neovim 0.10+)
      foldmethod = "expr";
      foldexpr = "v:lua.vim.treesitter.foldexpr()";
      foldenable = false;
    };

    # Global variables
    globals = {
      mapleader = " ";
      maplocalleader = " ";
    };

    # Autocommands
    autoGroups = {
      YankHighlight.clear = true;
      TrimWhitespace.clear = true;
      AutoCreateDir.clear = true;
      LastLocation.clear = true;
      CloseWithQ.clear = true;
      WrapSpell.clear = true;
    };

    autoCmd = [
      # Highlight on yank
      {
        event = "TextYankPost";
        group = "YankHighlight";
        callback.__raw = ''
          function()
            vim.highlight.on_yank({ higroup = "IncSearch", timeout = 200 })
          end
        '';
      }
      # Remove trailing whitespace on save
      {
        event = "BufWritePre";
        group = "TrimWhitespace";
        pattern = "*";
        command = "%s/\\s\\+$//e";
      }
      # Auto create dir when saving a file
      {
        event = "BufWritePre";
        group = "AutoCreateDir";
        callback.__raw = ''
          function(event)
            if event.match:match("^%w%w+://") then
              return
            end
            local file = vim.loop.fs_realpath(event.match) or event.match
            vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
          end
        '';
      }
      # Go to last location when opening a buffer
      {
        event = "BufReadPost";
        group = "LastLocation";
        callback.__raw = ''
          function()
            local mark = vim.api.nvim_buf_get_mark(0, '"')
            local lcount = vim.api.nvim_buf_line_count(0)
            if mark[1] > 0 and mark[1] <= lcount then
              pcall(vim.api.nvim_win_set_cursor, 0, mark)
            end
          end
        '';
      }
      # Close some filetypes with <q>
      {
        event = "FileType";
        group = "CloseWithQ";
        pattern = [
          "help"
          "lspinfo"
          "man"
          "notify"
          "qf"
          "checkhealth"
          "oil"
        ];
        callback.__raw = ''
          function(event)
            vim.bo[event.buf].buflisted = false
            vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
          end
        '';
      }
      # Wrap and check for spell in text filetypes
      {
        event = "FileType";
        group = "WrapSpell";
        pattern = [
          "gitcommit"
          "markdown"
        ];
        callback.__raw = ''
          function()
            vim.opt_local.wrap = true
            vim.opt_local.spell = true
          end
        '';
      }
    ];
  };
}
