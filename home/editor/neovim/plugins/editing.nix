_:

{
  programs.nixvim.plugins = {
    # nvim-autopairs: Auto-close brackets and quotes
    nvim-autopairs = {
      enable = true;
      lazyLoad.settings.event = [ "InsertEnter" ];
    };

    # mini: Collection of minimal modules (surround, ai textobjects)
    mini = {
      enable = true;
      mockDevIcons = false;
      modules = {
        surround = {
          mappings = {
            add = "sa";
            delete = "sd";
            find = "sf";
            find_left = "sF";
            highlight = "sh";
            replace = "sr";
            update_n_lines = "sn";
          };
        };
        ai = {
          n_lines = 500;
          custom_textobjects = {
            # Whole buffer
            g.__raw = ''
              function()
                local from = { line = 1, col = 1 }
                local to = { line = vim.fn.line('$'), col = math.max(vim.fn.getline('$'):len(), 1) }
                return { from = from, to = to }
              end
            '';
          };
        };
      };
    };

    # ts-comments: Context-aware commenting via treesitter
    ts-comments.enable = true;

    # todo-comments: Highlight and search TODO/FIXME comments
    todo-comments = {
      enable = true;
      lazyLoad.settings.event = [
        "BufReadPost"
        "BufNewFile"
      ];
    };

    # dial: Enhanced increment/decrement
    dial = {
      enable = true;
      lazyLoad.settings.keys = [
        {
          __unkeyed-1 = "<C-a>";
          __unkeyed-2.__raw = ''function() require("dial.map").manipulate("increment", "normal") end'';
          mode = "n";
          desc = "Increment";
        }
        {
          __unkeyed-1 = "<C-x>";
          __unkeyed-2.__raw = ''function() require("dial.map").manipulate("decrement", "normal") end'';
          mode = "n";
          desc = "Decrement";
        }
        {
          __unkeyed-1 = "g<C-a>";
          __unkeyed-2.__raw = ''function() require("dial.map").manipulate("increment", "gnormal") end'';
          mode = "n";
          desc = "Increment (additive)";
        }
        {
          __unkeyed-1 = "g<C-x>";
          __unkeyed-2.__raw = ''function() require("dial.map").manipulate("decrement", "gnormal") end'';
          mode = "n";
          desc = "Decrement (additive)";
        }
        {
          __unkeyed-1 = "<C-a>";
          __unkeyed-2.__raw = ''function() require("dial.map").manipulate("increment", "visual") end'';
          mode = "v";
          desc = "Increment";
        }
        {
          __unkeyed-1 = "<C-x>";
          __unkeyed-2.__raw = ''function() require("dial.map").manipulate("decrement", "visual") end'';
          mode = "v";
          desc = "Decrement";
        }
      ];
    };

    # trouble: Pretty diagnostics, quickfix, and location lists
    trouble = {
      enable = true;
      lazyLoad.settings = {
        cmd = [ "Trouble" ];
        keys = [
          {
            __unkeyed-1 = "<leader>xx";
            desc = "Diagnostics";
          }
          {
            __unkeyed-1 = "<leader>xX";
            desc = "Buffer diagnostics";
          }
          {
            __unkeyed-1 = "<leader>cs";
            desc = "Symbols";
          }
          {
            __unkeyed-1 = "<leader>cl";
            desc = "LSP";
          }
          {
            __unkeyed-1 = "<leader>xL";
            desc = "Location list";
          }
          {
            __unkeyed-1 = "<leader>xQ";
            desc = "Quickfix list";
          }
        ];
      };
      settings = {
        modes = {
          diagnostics = {
            auto_close = true;
            auto_preview = false;
          };
        };
      };
    };
  };
}
