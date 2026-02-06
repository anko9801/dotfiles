_:

{
  programs.nixvim.plugins = {
    # oil: Edit filesystem like a buffer
    oil = {
      enable = true;
      lazyLoad.settings = {
        cmd = [ "Oil" ];
        keys = [
          {
            __unkeyed-1 = "-";
            desc = "Open parent directory";
          }
          {
            __unkeyed-1 = "<leader>e";
            desc = "File explorer";
          }
        ];
      };
      settings = {
        view_options.show_hidden = true;
        skip_confirm_for_simple_edits = true;
        keymaps = {
          "g?" = "actions.show_help";
          "<CR>" = "actions.select";
          "<C-v>" = "actions.select_vsplit";
          "<C-s>" = "actions.select_split";
          "<C-p>" = "actions.preview";
          "<C-c>" = "actions.close";
          "-" = "actions.parent";
          "_" = "actions.open_cwd";
          "`" = "actions.cd";
          "~" = "actions.tcd";
          "gs" = "actions.change_sort";
          "gx" = "actions.open_external";
          "g." = "actions.toggle_hidden";
        };
      };
    };

    # fzf-lua: Fuzzy finder with fzf backend
    fzf-lua = {
      enable = true;
      lazyLoad.settings = {
        cmd = [ "FzfLua" ];
        keys = [
          {
            __unkeyed-1 = "<leader>ff";
            desc = "Find files";
          }
          {
            __unkeyed-1 = "<leader>fg";
            desc = "Live grep";
          }
          {
            __unkeyed-1 = "<leader>fb";
            desc = "Buffers";
          }
          {
            __unkeyed-1 = "<leader>fh";
            desc = "Help tags";
          }
          {
            __unkeyed-1 = "<leader>fr";
            desc = "Recent files";
          }
          {
            __unkeyed-1 = "<leader>gc";
            desc = "Git commits";
          }
          {
            __unkeyed-1 = "<leader>gs";
            desc = "Git status";
          }
        ];
      };
      settings = {
        winopts = {
          height = 0.85;
          width = 0.80;
          preview = {
            layout = "flex";
            flip_columns = 120;
          };
        };
        keymap.fzf = {
          "ctrl-q" = "select-all+accept";
          "ctrl-u" = "half-page-up";
          "ctrl-d" = "half-page-down";
        };
        files.fd_opts = "--type f --hidden --follow --exclude .git";
        grep.rg_opts = "--column --line-number --no-heading --color=always --smart-case";
      };
    };

    # harpoon: Quick file navigation and marks
    harpoon = {
      enable = true;
      lazyLoad.settings.keys = [
        {
          __unkeyed-1 = "<leader>ha";
          desc = "Harpoon add";
        }
        {
          __unkeyed-1 = "<leader>hh";
          desc = "Harpoon menu";
        }
        {
          __unkeyed-1 = "<leader>1";
          desc = "Harpoon 1";
        }
        {
          __unkeyed-1 = "<leader>2";
          desc = "Harpoon 2";
        }
        {
          __unkeyed-1 = "<leader>3";
          desc = "Harpoon 3";
        }
        {
          __unkeyed-1 = "<leader>4";
          desc = "Harpoon 4";
        }
      ];
    };

    # smart-splits: Seamless navigation between Neovim and tmux/zellij
    smart-splits = {
      enable = true;
      lazyLoad.settings.event = [ "BufEnter" ];
      settings = {
        ignored_filetypes = [
          "nofile"
          "quickfix"
          "prompt"
        ];
        ignored_buftypes = [ "NvimTree" ];
        default_amount = 3;
        at_edge = "stop";
      };
    };

    # portal: Enhanced jumplist/changelist navigation
    portal = {
      enable = true;
      lazyLoad.settings.keys = [
        {
          __unkeyed-1 = "<leader>o";
          __unkeyed-2.__raw = ''function() require("portal.builtin").jumplist.backward() end'';
          desc = "Portal backward";
        }
        {
          __unkeyed-1 = "<leader>i";
          __unkeyed-2.__raw = ''function() require("portal.builtin").jumplist.forward() end'';
          desc = "Portal forward";
        }
      ];
      settings = {
        window_options.border = "rounded";
      };
    };

    # flash: Fast motion and search with labels
    flash = {
      enable = true;
      lazyLoad.settings = {
        keys = [
          "s"
          "S"
        ];
      };
      settings = {
        labels = "asdfghjklqwertyuiopzxcvbnm";
        search.mode = "fuzzy";
        label.after = true;
        modes = {
          search.enabled = true;
          char.enabled = true;
        };
      };
    };
  };
}
