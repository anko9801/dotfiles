_:

{
  programs.nixvim.plugins = {
    # image: Display and paste images in terminal Neovim
    image = {
      enable = true;
      lazyLoad.settings = {
        event = [ "BufEnter" ];
        ft = [
          "markdown"
          "org"
          "norg"
        ];
      };
    };

    # toggleterm: Persistent terminal windows with toggle support
    toggleterm = {
      enable = true;
      lazyLoad.settings = {
        cmd = [ "ToggleTerm" ];
        keys = [
          {
            __unkeyed-1 = "<leader>tf";
            desc = "Float terminal";
          }
          {
            __unkeyed-1 = "<leader>th";
            desc = "Horizontal terminal";
          }
          {
            __unkeyed-1 = "<leader>tv";
            desc = "Vertical terminal";
          }
          {
            __unkeyed-1 = "<C-\\>";
            desc = "Toggle terminal";
          }
        ];
      };
      settings = {
        open_mapping.__raw = "[[<C-\\>]]";
        direction = "float";
        float_opts = {
          border = "curved";
          width = 120;
          height = 30;
        };
        size.__raw = ''
          function(term)
            if term.direction == "horizontal" then
              return 15
            elseif term.direction == "vertical" then
              return vim.o.columns * 0.4
            end
          end
        '';
      };
    };

    # persistence: Automatic session saving and restoring
    persistence = {
      enable = true;
      lazyLoad.settings = {
        event = [ "BufReadPre" ];
        keys = [
          {
            __unkeyed-1 = "<leader>qs";
            desc = "Restore session";
          }
          {
            __unkeyed-1 = "<leader>ql";
            desc = "Restore last session";
          }
          {
            __unkeyed-1 = "<leader>qd";
            desc = "Don't save session";
          }
        ];
      };
      settings = {
        dir.__raw = "vim.fn.stdpath('state') .. '/sessions/'";
        options = [
          "buffers"
          "curdir"
          "tabpages"
          "winsize"
        ];
      };
    };
  };
}
