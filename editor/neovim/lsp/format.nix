{ lib, ... }:

let
  prettierTypes = [
    "javascript"
    "typescript"
    "javascriptreact"
    "typescriptreact"
    "json"
    "yaml"
    "markdown"
  ];
in
{
  programs.nixvim.plugins = {
    lint = {
      enable = true;
      lintersByFt = {
        python = [ "ruff" ];
        javascript = [ "eslint_d" ];
        typescript = [ "eslint_d" ];
        nix = [ "statix" ];
      };
    };

    conform-nvim = {
      enable = true;
      lazyLoad.settings.event = [ "BufWritePre" ];
      settings = {
        formatters_by_ft = lib.genAttrs prettierTypes (_: [ "prettierd" ]) // {
          lua = [ "stylua" ];
          python = [
            "ruff_format"
            "ruff_organize_imports"
          ];
          go = [ "gofmt" ];
          rust = [ "rustfmt" ];
          nix = [ "nixfmt" ];
          terraform = [ "terraform_fmt" ];
          tf = [ "terraform_fmt" ];
          hcl = [ "terraform_fmt" ];
        };
        format_on_save = {
          timeout_ms = 500;
          lsp_format = "fallback";
        };
      };
    };
  };
}
