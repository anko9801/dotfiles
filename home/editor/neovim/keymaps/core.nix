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
      options = {
        silent = true;
        desc = "Down (wrapped)";
      };
    }
    {
      mode = [
        "n"
        "v"
      ];
      key = "k";
      action = "gk";
      options = {
        silent = true;
        desc = "Up (wrapped)";
      };
    }

    # Yank to end of line (consistent with D and C)
    {
      mode = "n";
      key = "Y";
      action = "y$";
      options.desc = "Yank to end of line";
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
      options.desc = "Beginning of line";
    }
    {
      mode = "c";
      key = "<C-e>";
      action = "<End>";
      options.desc = "End of line";
    }
    {
      mode = "c";
      key = "<C-b>";
      action = "<Left>";
      options.desc = "Left";
    }
    {
      mode = "c";
      key = "<C-f>";
      action = "<Right>";
      options.desc = "Right";
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
      options.desc = "Indent left";
    }
    {
      mode = "v";
      key = ">";
      action = ">gv";
      options.desc = "Indent right";
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

    # Format
    {
      mode = "n";
      key = "<leader>cf";
      action = "<cmd>lua require('conform').format()<CR>";
      options.desc = "Format file";
    }
  ];
}
