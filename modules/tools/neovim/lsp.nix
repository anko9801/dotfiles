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
        basedpyright = {
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
        keymap.preset = "default";
        appearance.nerd_font_variant = "mono";
        completion = {
          documentation.auto_show = true;
          ghost_text.enabled = true;
          menu.draw.treesitter = [ "lsp" ];
        };
        sources = {
          default = [
            "lsp"
            "path"
            "snippets"
            "buffer"
          ];
        };
        signature.enabled = true;
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
