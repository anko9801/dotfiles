_:

let
  flakeExpr = ''(builtins.getFlake (builtins.getEnv "HOME" + "/dotfiles"))'';
in
{
  programs.nixvim.plugins = {
    lsp = {
      enable = true;
      servers = {
        # All LSPs use package = null to share with VSCode/other editors via PATH
        nixd = {
          enable = true;
          package = null; # dev/nix.nix
          settings.nixd = {
            nixpkgs.expr = "import (builtins.getFlake \"nixpkgs\") { }";
            options = {
              # Evaluated impurely by nixd at runtime via builtins.getEnv
              home-manager.expr = "${flakeExpr}.homeConfigurations.\"linux-wsl\".options";
              nix-darwin.expr = "${flakeExpr}.darwinConfigurations.\"mac-arm\".options";
            };
            formatting.command = [ "nixfmt" ];
          };
        };
        lua_ls = {
          enable = true;
          package = null; # neovim.nix extraPackages
          settings.Lua = {
            runtime.version = "LuaJIT";
            diagnostics.globals = [ "vim" ];
            workspace.checkThirdParty = false;
            telemetry.enable = false;
          };
        };
        ts_ls = {
          enable = true;
          package = null; # dev/node.nix
        };
        rust_analyzer = {
          enable = true;
          package = null; # dev/rust.nix (rustup)
          installCargo = false;
          installRustc = false;
          settings.rust-analyzer.check.command = "clippy";
        };
        ty = {
          enable = true;
          package = null; # dev/python.nix (mise)
        };
        ruff = {
          enable = true;
          package = null; # neovim.nix extraPackages
        };
        gopls = {
          enable = true;
          package = null; # dev/go.nix
        };
        yamlls = {
          enable = true;
          package = null; # neovim.nix extraPackages
          settings.yaml = {
            schemas = {
              kubernetes = "/*.k8s.yaml";
              "http://json.schemastore.org/github-workflow" = ".github/workflows/*";
              "http://json.schemastore.org/github-action" = ".github/action.{yml,yaml}";
              "http://json.schemastore.org/prettierrc" = ".prettierrc.{yml,yaml}";
            };
            validate = true;
            completion = true;
            hover = true;
          };
        };
        helm_ls = {
          enable = true;
          package = null; # mise
          settings.helm-ls = {
            yamlls.path = "yaml-language-server";
          };
        };
        terraformls = {
          enable = true;
          package = null; # mise
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

    fidget = {
      enable = true;
      lazyLoad.settings.event = [ "LspAttach" ];
    };
  };
}
