_:

{
  programs.nixvim.plugins = {
    blink-cmp = {
      enable = true;
      settings = {
        keymap = {
          preset = "default";
          "<C-space>" = [
            "show"
            "show_documentation"
            "hide_documentation"
          ];
          "<C-e>" = [ "hide" ];
          "<CR>" = [
            "accept"
            "fallback"
          ];
          "<Tab>" = [
            "select_next"
            "snippet_forward"
            "fallback"
          ];
          "<S-Tab>" = [
            "select_prev"
            "snippet_backward"
            "fallback"
          ];
          "<C-p>" = [
            "select_prev"
            "fallback"
          ];
          "<C-n>" = [
            "select_next"
            "fallback"
          ];
          "<C-u>" = [
            "scroll_documentation_up"
            "fallback"
          ];
          "<C-d>" = [
            "scroll_documentation_down"
            "fallback"
          ];
        };
        appearance = {
          nerd_font_variant = "mono";
          kind_icons = {
            Text = "󰉿";
            Method = "󰆧";
            Function = "󰊕";
            Constructor = "";
            Field = "󰜢";
            Variable = "󰀫";
            Class = "󰠱";
            Interface = "";
            Module = "";
            Property = "󰜢";
            Unit = "󰑭";
            Value = "󰎠";
            Enum = "";
            Keyword = "󰌋";
            Snippet = "";
            Color = "󰏘";
            File = "󰈙";
            Reference = "󰈇";
            Folder = "󰉋";
            EnumMember = "";
            Constant = "󰏿";
            Struct = "󰙅";
            Event = "";
            Operator = "󰆕";
            TypeParameter = "";
            Copilot = "";
          };
        };
        completion = {
          documentation = {
            auto_show = true;
            auto_show_delay_ms = 200;
            window.border = "rounded";
          };
          ghost_text.enabled = true;
          menu = {
            border = "rounded";
            draw = {
              treesitter = [ "lsp" ];
              columns = [
                { __unkeyed-1 = "kind_icon"; }
                {
                  __unkeyed-1 = "label";
                  __unkeyed-2 = "label_description";
                  gap = 1;
                }
                { __unkeyed-1 = "source_name"; }
              ];
            };
          };
          list.selection = {
            preselect = true;
            auto_insert = false;
          };
        };
        sources = {
          default = [
            "lsp"
            "path"
            "snippets"
            "buffer"
          ];
          providers = {
            lsp.score_offset = 100;
            snippets.score_offset = 80;
            path.score_offset = 50;
            buffer = {
              score_offset = 30;
              min_keyword_length = 3;
            };
          };
        };
        signature = {
          enabled = true;
          window.border = "rounded";
        };
      };
    };

    luasnip = {
      enable = true;
      fromVscode = [ { } ];
    };
    friendly-snippets.enable = true;
  };
}
