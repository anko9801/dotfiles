_:

{
  programs.nixvim.keymaps = [
    # Better j/k navigation (wrapped lines)
    {
      mode = [
        "n"
        "v"
      ];
      key = "j";
      action = "gj";
      options.silent = true;
    }
    {
      mode = [
        "n"
        "v"
      ];
      key = "k";
      action = "gk";
      options.silent = true;
    }

    # Yank to end of line (consistent with D and C)
    {
      mode = "n";
      key = "Y";
      action = "y$";
    }

    # Keep cursor centered when searching
    {
      mode = "n";
      key = "n";
      action = "nzzzv";
      options.desc = "Next search result (centered)";
    }
    {
      mode = "n";
      key = "N";
      action = "Nzzzv";
      options.desc = "Previous search result (centered)";
    }

    # Keep cursor centered when joining lines
    {
      mode = "n";
      key = "J";
      action = "mzJ`z";
      options.desc = "Join lines (keep cursor)";
    }

    # Quick escape from insert mode
    {
      mode = "i";
      key = "jk";
      action = "<Esc>";
      options.desc = "Escape";
    }

    # QuickFix navigation
    {
      mode = "n";
      key = "]q";
      action = "<cmd>cnext<CR>zz";
      options.desc = "Next quickfix";
    }
    {
      mode = "n";
      key = "[q";
      action = "<cmd>cprevious<CR>zz";
      options.desc = "Previous quickfix";
    }
    {
      mode = "n";
      key = "<leader>xq";
      action = "<cmd>copen<CR>";
      options.desc = "Open quickfix";
    }

    # Command-line navigation (Emacs style)
    {
      mode = "c";
      key = "<C-a>";
      action = "<Home>";
    }
    {
      mode = "c";
      key = "<C-e>";
      action = "<End>";
    }
    {
      mode = "c";
      key = "<C-b>";
      action = "<Left>";
    }
    {
      mode = "c";
      key = "<C-f>";
      action = "<Right>";
    }

    # Window navigation (smart-splits: works across nvim/tmux/zellij)
    {
      mode = "n";
      key = "<C-h>";
      action.__raw = "function() require('smart-splits').move_cursor_left() end";
      options.desc = "Move to left window";
    }
    {
      mode = "n";
      key = "<C-j>";
      action.__raw = "function() require('smart-splits').move_cursor_down() end";
      options.desc = "Move to lower window";
    }
    {
      mode = "n";
      key = "<C-k>";
      action.__raw = "function() require('smart-splits').move_cursor_up() end";
      options.desc = "Move to upper window";
    }
    {
      mode = "n";
      key = "<C-l>";
      action.__raw = "function() require('smart-splits').move_cursor_right() end";
      options.desc = "Move to right window";
    }

    # Window resize (smart-splits)
    {
      mode = "n";
      key = "<C-Left>";
      action.__raw = "function() require('smart-splits').resize_left() end";
      options.desc = "Resize window left";
    }
    {
      mode = "n";
      key = "<C-Down>";
      action.__raw = "function() require('smart-splits').resize_down() end";
      options.desc = "Resize window down";
    }
    {
      mode = "n";
      key = "<C-Up>";
      action.__raw = "function() require('smart-splits').resize_up() end";
      options.desc = "Resize window up";
    }
    {
      mode = "n";
      key = "<C-Right>";
      action.__raw = "function() require('smart-splits').resize_right() end";
      options.desc = "Resize window right";
    }

    # Clear search highlight
    {
      mode = "n";
      key = "<Esc>";
      action = "<cmd>nohlsearch<CR>";
      options.desc = "Clear search highlight";
    }

    # Better indenting
    {
      mode = "v";
      key = "<";
      action = "<gv";
    }
    {
      mode = "v";
      key = ">";
      action = ">gv";
    }

    # Move lines
    {
      mode = "n";
      key = "<A-j>";
      action = "<cmd>m .+1<CR>==";
      options.desc = "Move line down";
    }
    {
      mode = "n";
      key = "<A-k>";
      action = "<cmd>m .-2<CR>==";
      options.desc = "Move line up";
    }
    {
      mode = "v";
      key = "<A-j>";
      action = ":m '>+1<CR>gv=gv";
      options.desc = "Move selection down";
    }
    {
      mode = "v";
      key = "<A-k>";
      action = ":m '<-2<CR>gv=gv";
      options.desc = "Move selection up";
    }

    # Buffer navigation
    {
      mode = "n";
      key = "<S-h>";
      action = "<cmd>bprevious<CR>";
      options.desc = "Previous buffer";
    }
    {
      mode = "n";
      key = "<S-l>";
      action = "<cmd>bnext<CR>";
      options.desc = "Next buffer";
    }

    # Save and quit
    {
      mode = "n";
      key = "<leader>w";
      action = "<cmd>w<CR>";
      options.desc = "Save file";
    }
    {
      mode = "n";
      key = "<leader>q";
      action = "<cmd>q<CR>";
      options.desc = "Quit";
    }
    {
      mode = "n";
      key = "<leader>Q";
      action = "<cmd>qa!<CR>";
      options.desc = "Quit all force";
    }

    # Split windows
    {
      mode = "n";
      key = "<leader>sv";
      action = "<C-w>v";
      options.desc = "Split window vertically";
    }
    {
      mode = "n";
      key = "<leader>sh";
      action = "<C-w>s";
      options.desc = "Split window horizontally";
    }
    {
      mode = "n";
      key = "<leader>se";
      action = "<C-w>=";
      options.desc = "Make splits equal size";
    }
    {
      mode = "n";
      key = "<leader>sx";
      action = "<cmd>close<CR>";
      options.desc = "Close current split";
    }

    # Tabs
    {
      mode = "n";
      key = "<leader>to";
      action = "<cmd>tabnew<CR>";
      options.desc = "Open new tab";
    }
    {
      mode = "n";
      key = "<leader>tx";
      action = "<cmd>tabclose<CR>";
      options.desc = "Close current tab";
    }
    {
      mode = "n";
      key = "<leader>tn";
      action = "<cmd>tabn<CR>";
      options.desc = "Go to next tab";
    }
    {
      mode = "n";
      key = "<leader>tp";
      action = "<cmd>tabp<CR>";
      options.desc = "Go to previous tab";
    }

    # File explorer (oil.nvim)
    {
      mode = "n";
      key = "<leader>e";
      action = "<cmd>Oil<CR>";
      options.desc = "Open file explorer";
    }

    # Oil.nvim (edit filesystem like buffer)
    {
      mode = "n";
      key = "-";
      action = "<cmd>Oil<CR>";
      options.desc = "Open parent directory";
    }

    # Format
    {
      mode = "n";
      key = "<leader>cf";
      action = "<cmd>lua require('conform').format()<CR>";
      options.desc = "Format file";
    }

    # Lazygit (using built-in terminal)
    {
      mode = "n";
      key = "<leader>gg";
      action.__raw = ''
        function()
          vim.cmd("tabnew | terminal lazygit")
          vim.cmd("startinsert")
        end
      '';
      options.desc = "Lazygit";
    }

    # Diffview
    {
      mode = "n";
      key = "<leader>gd";
      action = "<cmd>DiffviewOpen<CR>";
      options.desc = "Git diff";
    }
    {
      mode = "n";
      key = "<leader>gD";
      action = "<cmd>DiffviewClose<CR>";
      options.desc = "Close diff";
    }

    # Harpoon
    {
      mode = "n";
      key = "<leader>a";
      action.__raw = "function() require('harpoon'):list():add() end";
      options.desc = "Harpoon add file";
    }
    {
      mode = "n";
      key = "<leader>h";
      action.__raw = "function() require('harpoon').ui:toggle_quick_menu(require('harpoon'):list()) end";
      options.desc = "Harpoon menu";
    }
    {
      mode = "n";
      key = "<leader>1";
      action.__raw = "function() require('harpoon'):list():select(1) end";
      options.desc = "Harpoon file 1";
    }
    {
      mode = "n";
      key = "<leader>2";
      action.__raw = "function() require('harpoon'):list():select(2) end";
      options.desc = "Harpoon file 2";
    }
    {
      mode = "n";
      key = "<leader>3";
      action.__raw = "function() require('harpoon'):list():select(3) end";
      options.desc = "Harpoon file 3";
    }
    {
      mode = "n";
      key = "<leader>4";
      action.__raw = "function() require('harpoon'):list():select(4) end";
      options.desc = "Harpoon file 4";
    }

    # fzf-lua keymaps
    {
      mode = "n";
      key = "<leader>ff";
      action = "<cmd>FzfLua files<CR>";
      options.desc = "Find files";
    }
    {
      mode = "n";
      key = "<leader>fg";
      action = "<cmd>FzfLua live_grep<CR>";
      options.desc = "Live grep";
    }
    {
      mode = "n";
      key = "<leader>fb";
      action = "<cmd>FzfLua buffers<CR>";
      options.desc = "Buffers";
    }
    {
      mode = "n";
      key = "<leader>fh";
      action = "<cmd>FzfLua help_tags<CR>";
      options.desc = "Help tags";
    }
    {
      mode = "n";
      key = "<leader>fr";
      action = "<cmd>FzfLua oldfiles<CR>";
      options.desc = "Recent files";
    }
    {
      mode = "n";
      key = "<leader>gc";
      action = "<cmd>FzfLua git_commits<CR>";
      options.desc = "Git commits";
    }
    {
      mode = "n";
      key = "<leader>gs";
      action = "<cmd>FzfLua git_status<CR>";
      options.desc = "Git status";
    }

    # Octo (GitHub)
    {
      mode = "n";
      key = "<leader>op";
      action = "<cmd>Octo pr list<CR>";
      options.desc = "List PRs";
    }
    {
      mode = "n";
      key = "<leader>oi";
      action = "<cmd>Octo issue list<CR>";
      options.desc = "List issues";
    }
    {
      mode = "n";
      key = "<leader>or";
      action = "<cmd>Octo review start<CR>";
      options.desc = "Start review";
    }

    # Flash keymaps
    {
      mode = [
        "n"
        "x"
        "o"
      ];
      key = "s";
      action.__raw = "function() require('flash').jump() end";
      options.desc = "Flash jump";
    }
    {
      mode = [
        "n"
        "x"
        "o"
      ];
      key = "S";
      action.__raw = "function() require('flash').treesitter() end";
      options.desc = "Flash treesitter";
    }
    {
      mode = "o";
      key = "r";
      action.__raw = "function() require('flash').remote() end";
      options.desc = "Flash remote";
    }

    # Avante (AI) keymaps
    {
      mode = "n";
      key = "<leader>aa";
      action = "<cmd>AvanteAsk<CR>";
      options.desc = "Avante: Ask AI";
    }
    {
      mode = "v";
      key = "<leader>aa";
      action = "<cmd>AvanteAsk<CR>";
      options.desc = "Avante: Ask AI (selection)";
    }
    {
      mode = "n";
      key = "<leader>ae";
      action = "<cmd>AvanteEdit<CR>";
      options.desc = "Avante: Edit";
    }
    {
      mode = "v";
      key = "<leader>ae";
      action = "<cmd>AvanteEdit<CR>";
      options.desc = "Avante: Edit (selection)";
    }
    {
      mode = "n";
      key = "<leader>at";
      action = "<cmd>AvanteToggle<CR>";
      options.desc = "Avante: Toggle";
    }
    {
      mode = "n";
      key = "<leader>ar";
      action = "<cmd>AvanteRefresh<CR>";
      options.desc = "Avante: Refresh";
    }

    # Toggleterm
    {
      mode = "n";
      key = "<leader>tf";
      action = "<cmd>ToggleTerm direction=float<CR>";
      options.desc = "Float terminal";
    }
    {
      mode = "n";
      key = "<leader>th";
      action = "<cmd>ToggleTerm direction=horizontal<CR>";
      options.desc = "Horizontal terminal";
    }
    {
      mode = "n";
      key = "<leader>tv";
      action = "<cmd>ToggleTerm direction=vertical<CR>";
      options.desc = "Vertical terminal";
    }
    {
      mode = "t";
      key = "<C-\\>";
      action = "<cmd>ToggleTerm<CR>";
      options.desc = "Toggle terminal";
    }
    {
      mode = "t";
      key = "<Esc><Esc>";
      action = "<C-\\><C-n>";
      options.desc = "Exit terminal mode";
    }

    # Session (persistence)
    {
      mode = "n";
      key = "<leader>qs";
      action.__raw = "function() require('persistence').load() end";
      options.desc = "Restore session";
    }
    {
      mode = "n";
      key = "<leader>ql";
      action.__raw = "function() require('persistence').load({ last = true }) end";
      options.desc = "Restore last session";
    }
    {
      mode = "n";
      key = "<leader>qd";
      action.__raw = "function() require('persistence').stop() end";
      options.desc = "Don't save session";
    }

    # Trouble (diagnostics)
    {
      mode = "n";
      key = "<leader>xx";
      action = "<cmd>Trouble diagnostics toggle<CR>";
      options.desc = "Diagnostics (Trouble)";
    }
    {
      mode = "n";
      key = "<leader>xX";
      action = "<cmd>Trouble diagnostics toggle filter.buf=0<CR>";
      options.desc = "Buffer Diagnostics (Trouble)";
    }
    {
      mode = "n";
      key = "<leader>cs";
      action = "<cmd>Trouble symbols toggle focus=false<CR>";
      options.desc = "Symbols (Trouble)";
    }
    {
      mode = "n";
      key = "<leader>cl";
      action = "<cmd>Trouble lsp toggle focus=false win.position=right<CR>";
      options.desc = "LSP (Trouble)";
    }
    {
      mode = "n";
      key = "<leader>xL";
      action = "<cmd>Trouble loclist toggle<CR>";
      options.desc = "Location List (Trouble)";
    }
    {
      mode = "n";
      key = "<leader>xQ";
      action = "<cmd>Trouble qflist toggle<CR>";
      options.desc = "Quickfix List (Trouble)";
    }
  ];
}
