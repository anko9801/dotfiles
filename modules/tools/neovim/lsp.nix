_:

{
  programs.nixvim.plugins = {
    # LSP
    lsp = {
      enable = true;
      servers = {
        # All LSPs use package = null to share with VSCode/other editors via PATH
        nixd = {
          enable = true;
          package = null;
          settings.nixd = {
            nixpkgs.expr = "import (builtins.getFlake \"nixpkgs\") { }";
            formatting.command = [ "nixfmt" ];
          };
        };
        lua_ls = {
          enable = true;
          package = null;
          settings.Lua = {
            runtime.version = "LuaJIT";
            diagnostics.globals = [ "vim" ];
            workspace.checkThirdParty = false;
            telemetry.enable = false;
          };
        };
        ts_ls = {
          enable = true;
          package = null;
        };
        rust_analyzer = {
          enable = true;
          package = null; # Provided by rustup
          installCargo = false;
          installRustc = false;
          settings.rust-analyzer.check.command = "clippy";
        };
        pyright = {
          enable = true;
          package = null;
        };
        ruff = {
          enable = true;
          package = null; # Installed in linters.nix
        };
        gopls = {
          enable = true;
          package = null;
        };
      };
      keymaps = {
        lspBuf = {
          "gd" = "definition";
          "gD" = "declaration";
          "gI" = "implementation";
          "gr" = "references";
          "K" = "hover";
          "<leader>rn" = "rename";
          "<leader>ca" = "code_action";
        };
        diagnostic = {
          "<leader>d" = "open_float";
          "[d" = "goto_prev";
          "]d" = "goto_next";
        };
      };
    };

    # LSP progress indicator
    fidget = {
      enable = true;
      lazyLoad.settings.event = [ "LspAttach" ];
    };

    # Linting (separate from formatting)
    lint = {
      enable = true;
      lintersByFt = {
        python = [ "ruff" ];
        javascript = [ "eslint_d" ];
        typescript = [ "eslint_d" ];
        nix = [ "statix" ];
      };
    };

    # Formatter
    conform-nvim = {
      enable = true;
      lazyLoad.settings.event = [ "BufWritePre" ];
      settings = {
        formatters_by_ft = {
          lua = [ "stylua" ];
          python = [
            "ruff_format"
            "ruff_organize_imports"
          ];
          javascript = [ "prettierd" ];
          typescript = [ "prettierd" ];
          javascriptreact = [ "prettierd" ];
          typescriptreact = [ "prettierd" ];
          json = [ "prettierd" ];
          yaml = [ "prettierd" ];
          markdown = [ "prettierd" ];
          go = [ "gofmt" ];
          rust = [ "rustfmt" ];
          nix = [ "nixfmt" ];
        };
        format_on_save = {
          timeout_ms = 500;
          lsp_format = "fallback";
        };
      };
    };

    # Completion: blink.cmp (replaces nvim-cmp in 2025)
    blink-cmp = {
      enable = true;
      settings = {
        keymap = {
          preset = "default";
          "<C-space>" = [ "show" "show_documentation" "hide_documentation" ];
          "<C-e>" = [ "hide" ];
          "<CR>" = [ "accept" "fallback" ];
          "<Tab>" = [ "select_next" "snippet_forward" "fallback" ];
          "<S-Tab>" = [ "select_prev" "snippet_backward" "fallback" ];
          "<C-p>" = [ "select_prev" "fallback" ];
          "<C-n>" = [ "select_next" "fallback" ];
          "<C-u>" = [ "scroll_documentation_up" "fallback" ];
          "<C-d>" = [ "scroll_documentation_down" "fallback" ];
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
                { __unkeyed-1 = "label"; __unkeyed-2 = "label_description"; gap = 1; }
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

    # Snippets
    luasnip = {
      enable = true;
      fromVscode = [ { } ];
    };
    friendly-snippets.enable = true;
  };
}
