_:

{
  programs.nixvim.keymaps = [
    # Git: Lazygit (using built-in terminal)
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

    # Git: Diffview
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

    # Git: fzf-lua
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

    # Git: Octo (GitHub)
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

    # AI: Avante
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

    # Terminal: Toggleterm
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

    # Session: Persistence
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

    # Diagnostics: Trouble
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
