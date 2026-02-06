_:

{
  programs.nixvim.plugins = {
    # web-devicons: File type icons for various plugins
    web-devicons.enable = true;

    # lualine: Fast and customizable statusline
    lualine = {
      enable = true;
      settings.options = {
        theme = "tokyonight";
        globalstatus = true; # Single statusline for all windows
        component_separators = {
          left = "";
          right = "";
        };
        section_separators = {
          left = "";
          right = "";
        };
      };
    };

    # indent-blankline: Visual indentation guides
    indent-blankline = {
      enable = true;
      lazyLoad.settings.event = [
        "BufReadPost"
        "BufNewFile"
      ];
      settings = {
        indent = {
          char = "│";
          tab_char = "│";
        };
        scope.enabled = false;
      };
    };

    # noice: Modern UI for messages, cmdline, and popupmenu
    noice = {
      enable = true;
      lazyLoad.settings.event = [
        "BufReadPost"
        "BufNewFile"
      ];
      settings = {
        lsp.override = {
          "vim.lsp.util.convert_input_to_markdown_lines" = true;
          "vim.lsp.util.stylize_markdown" = true;
          "cmp.entry.get_documentation" = true;
        };
        presets = {
          bottom_search = true;
          command_palette = true;
          long_message_to_split = true;
        };
      };
    };

    # notify: Notification manager with animations
    notify = {
      enable = true;
      lazyLoad.settings.event = [
        "BufReadPost"
        "BufNewFile"
      ];
      settings = {
        timeout = 3000;
        max_height.__raw = "function() return math.floor(vim.o.lines * 0.75) end";
        max_width.__raw = "function() return math.floor(vim.o.columns * 0.75) end";
      };
    };

    # which-key: Display keybinding hints in popup
    which-key = {
      enable = true;
      lazyLoad.settings.event = [
        "BufReadPost"
        "BufNewFile"
      ];
      settings = {
        delay = 200;
        icons.mappings = false;
        spec = [
          {
            __unkeyed-1 = "<leader>f";
            group = "find";
          }
          {
            __unkeyed-1 = "<leader>g";
            group = "git";
          }
          {
            __unkeyed-1 = "<leader>h";
            group = "harpoon/hunk";
          }
          {
            __unkeyed-1 = "<leader>o";
            group = "octo";
          }
          {
            __unkeyed-1 = "<leader>q";
            group = "session";
          }
          {
            __unkeyed-1 = "<leader>s";
            group = "split";
          }
          {
            __unkeyed-1 = "<leader>t";
            group = "terminal/tab";
          }
          {
            __unkeyed-1 = "<leader>x";
            group = "diagnostics";
          }
          {
            __unkeyed-1 = "<leader>a";
            group = "ai";
          }
          {
            __unkeyed-1 = "<leader>c";
            group = "code";
          }
        ];
      };
    };
  };
}
