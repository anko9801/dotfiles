{ pkgs, ... }:

{
  programs.nixvim.plugins = {
    # treesitter: Syntax highlighting and code parsing
    treesitter = {
      enable = true;
      nixvimInjections = true;
      lazyLoad.settings.event = [
        "BufReadPost"
        "BufNewFile"
      ];
      settings = {
        highlight.enable = true;
        indent.enable = true;
        incremental_selection = {
          enable = true;
          keymaps = {
            init_selection = "<C-space>";
            node_incremental = "<C-space>";
            scope_incremental = false;
            node_decremental = "<bs>";
          };
        };
      };
      grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
        bash
        c
        cpp
        css
        dockerfile
        go
        gomod
        helm
        html
        javascript
        json
        lua
        markdown
        markdown_inline
        nix
        python
        rust
        sql
        toml
        terraform
        tsx
        typescript
        hcl
        yaml
      ];
    };

    # treesitter-textobjects: Text objects based on syntax tree
    treesitter-textobjects = {
      enable = true;
      settings = {
        select = {
          enable = true;
          lookahead = true;
          keymaps = {
            "af" = "@function.outer";
            "if" = "@function.inner";
            "ac" = "@class.outer";
            "ic" = "@class.inner";
            "aa" = "@parameter.outer";
            "ia" = "@parameter.inner";
          };
        };
        move = {
          enable = true;
          set_jumps = true;
          goto_next_start = {
            "]f" = "@function.outer";
            "]c" = "@class.outer";
          };
          goto_previous_start = {
            "[f" = "@function.outer";
            "[c" = "@class.outer";
          };
        };
      };
    };

    # treesitter-context: Show code context at top of buffer
    treesitter-context = {
      enable = true;
      lazyLoad.settings.event = [ "BufReadPost" ];
      settings.max_lines = 3;
    };

    # ts-autotag: Auto close and rename HTML/JSX tags
    ts-autotag = {
      enable = true;
      lazyLoad.settings.event = [ "InsertEnter" ];
    };
  };
}
