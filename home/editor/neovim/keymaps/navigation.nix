_:

{
  programs.nixvim.keymaps = [
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

    # Harpoon
    {
      mode = "n";
      key = "<leader>ha";
      action.__raw = "function() require('harpoon'):list():add() end";
      options.desc = "Harpoon add file";
    }
    {
      mode = "n";
      key = "<leader>hh";
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
  ];
}
