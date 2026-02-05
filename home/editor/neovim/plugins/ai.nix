{
  pkgs,
  ...
}:

{
  programs.nixvim = {
    # External plugins not in nixvim
    extraPlugins = with pkgs.vimPlugins; [
      # Claude Code integration (AI pair programming)
      claudecode-nvim

      # YAML/Kubernetes schema companion
      schema-companion-nvim
    ];

    # Configuration for external plugins
    extraConfigLua = ''
      -- Claude Code integration
      require("claudecode").setup({
        terminal_cmd = nil, -- Use default terminal
      })

      -- Schema companion for YAML/Kubernetes
      require("schema-companion").setup({
        log_level = vim.log.levels.INFO,
      })

      -- Schema companion keymaps
      vim.keymap.set("n", "<leader>ys", function()
        require("schema-companion").select_schema()
      end, { desc = "Select YAML Schema" })
      vim.keymap.set("n", "<leader>ym", function()
        require("schema-companion").select_from_matching_schema()
      end, { desc = "Select from Matching Schemas" })
    '';
  };

  programs.nixvim.plugins = {
    # avante: Cursor-like AI assistant with Claude integration
    avante = {
      enable = true;
      lazyLoad.settings = {
        cmd = [
          "AvanteAsk"
          "AvanteEdit"
          "AvanteToggle"
        ];
        keys = [
          {
            __unkeyed-1 = "<leader>aa";
            desc = "Ask AI";
          }
          {
            __unkeyed-1 = "<leader>ae";
            desc = "Edit with AI";
          }
          {
            __unkeyed-1 = "<leader>at";
            desc = "Toggle Avante";
          }
          {
            __unkeyed-1 = "<leader>ar";
            desc = "Refresh Avante";
          }
        ];
      };
      settings = {
        provider = "claude";
        claude = {
          endpoint = "https://api.anthropic.com";
          model = "claude-sonnet-4-20250514";
          max_tokens = 4096;
        };
        behaviour = {
          auto_suggestions = false;
          auto_set_keymaps = true;
        };
        windows = {
          position = "right";
          width = 30;
        };
      };
    };
  };
}
