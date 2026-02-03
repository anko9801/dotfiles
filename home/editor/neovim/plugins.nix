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
    # Lazy loading with lz.n
    lz-n.enable = true;

    # ==========================================================================
    # UI (load immediately - needed for visual consistency)
    # ==========================================================================
    web-devicons.enable = true;

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

    # Noice: better UI for messages, cmdline, popupmenu
    noice = {
      enable = true;
      lazyLoad.settings.event = [ "VeryLazy" ];
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

    notify = {
      enable = true;
      lazyLoad.settings.event = [ "VeryLazy" ];
      settings = {
        timeout = 3000;
        max_height.__raw = "function() return math.floor(vim.o.lines * 0.75) end";
        max_width.__raw = "function() return math.floor(vim.o.columns * 0.75) end";
      };
    };

    # ==========================================================================
    # File explorer & Fuzzy finder (lazy load on command)
    # ==========================================================================
    oil = {
      enable = true;
      lazyLoad.settings.cmd = [ "Oil" ];
      settings = {
        view_options.show_hidden = true;
        skip_confirm_for_simple_edits = true;
        keymaps = {
          "g?" = "actions.show_help";
          "<CR>" = "actions.select";
          "<C-v>" = "actions.select_vsplit";
          "<C-s>" = "actions.select_split";
          "<C-p>" = "actions.preview";
          "<C-c>" = "actions.close";
          "-" = "actions.parent";
          "_" = "actions.open_cwd";
          "`" = "actions.cd";
          "~" = "actions.tcd";
          "gs" = "actions.change_sort";
          "gx" = "actions.open_external";
          "g." = "actions.toggle_hidden";
        };
      };
    };

    fzf-lua = {
      enable = true;
      lazyLoad.settings.cmd = [ "FzfLua" ];
      settings = {
        winopts = {
          height = 0.85;
          width = 0.80;
          preview = {
            layout = "flex";
            flip_columns = 120;
          };
        };
        keymap.fzf = {
          "ctrl-q" = "select-all+accept";
          "ctrl-u" = "half-page-up";
          "ctrl-d" = "half-page-down";
        };
        files.fd_opts = "--type f --hidden --follow --exclude .git";
        grep.rg_opts = "--column --line-number --no-heading --color=always --smart-case";
      };
    };

    harpoon = {
      enable = true;
      enableTelescope = false;
      lazyLoad.settings.event = [ "VeryLazy" ];
    };

    # ==========================================================================
    # Motion & Navigation
    # ==========================================================================
    flash = {
      enable = true;
      lazyLoad.settings = {
        event = [ "VeryLazy" ];
        keys = [
          "s"
          "S"
        ];
      };
      settings = {
        labels = "asdfghjklqwertyuiopzxcvbnm";
        search.mode = "fuzzy";
        label.after = true;
        modes = {
          search.enabled = true;
          char.enabled = true;
        };
      };
    };

    # ==========================================================================
    # Treesitter (load on file open)
    # ==========================================================================
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

    treesitter-context = {
      enable = true;
      lazyLoad.settings.event = [ "BufReadPost" ];
      settings.max_lines = 3;
    };

    ts-autotag = {
      enable = true;
      lazyLoad.settings.event = [ "InsertEnter" ];
    };

    # ==========================================================================
    # Git (lazy load)
    # ==========================================================================
    gitsigns = {
      enable = true;
      lazyLoad.settings.event = [
        "BufReadPost"
        "BufNewFile"
      ];
      settings = {
        signs = {
          add.text = "│";
          change.text = "│";
          delete.text = "_";
          topdelete.text = "‾";
          changedelete.text = "~";
          untracked.text = "┆";
        };
        signs_staged_enable = true;
        current_line_blame = true;
        on_attach.__raw = ''
          function(bufnr)
            local gs = package.loaded.gitsigns
            local function map(mode, l, r, opts)
              opts = opts or {}
              opts.buffer = bufnr
              vim.keymap.set(mode, l, r, opts)
            end
            map("n", "]c", function()
              if vim.wo.diff then return "]c" end
              vim.schedule(function() gs.next_hunk() end)
              return "<Ignore>"
            end, { expr = true, desc = "Next hunk" })
            map("n", "[c", function()
              if vim.wo.diff then return "[c" end
              vim.schedule(function() gs.prev_hunk() end)
              return "<Ignore>"
            end, { expr = true, desc = "Previous hunk" })
            map("n", "<leader>hs", gs.stage_hunk, { desc = "Stage hunk" })
            map("n", "<leader>hr", gs.reset_hunk, { desc = "Reset hunk" })
            map("v", "<leader>hs", function() gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, { desc = "Stage hunk" })
            map("v", "<leader>hr", function() gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, { desc = "Reset hunk" })
            map("n", "<leader>hS", gs.stage_buffer, { desc = "Stage buffer" })
            map("n", "<leader>hu", gs.undo_stage_hunk, { desc = "Undo stage hunk" })
            map("n", "<leader>hR", gs.reset_buffer, { desc = "Reset buffer" })
            map("n", "<leader>hp", gs.preview_hunk, { desc = "Preview hunk" })
            map("n", "<leader>hb", function() gs.blame_line({ full = true }) end, { desc = "Blame line" })
            map("n", "<leader>tb", gs.toggle_current_line_blame, { desc = "Toggle blame" })
            map("n", "<leader>hd", gs.diffthis, { desc = "Diff this" })
            map("n", "<leader>hD", function() gs.diffthis("~") end, { desc = "Diff this ~" })
            map("n", "<leader>td", gs.toggle_deleted, { desc = "Toggle deleted" })
          end
        '';
      };
    };

    diffview = {
      enable = true;
      lazyLoad.settings.cmd = [
        "DiffviewOpen"
        "DiffviewFileHistory"
      ];
    };

    git-conflict = {
      enable = true;
      lazyLoad.settings.event = [ "BufReadPost" ];
      settings.default_mappings = true;
    };

    # ==========================================================================
    # Editing (lazy load on events)
    # ==========================================================================
    nvim-autopairs = {
      enable = true;
      lazyLoad.settings.event = [ "InsertEnter" ];
    };

    # mini.surround (lighter than nvim-surround)
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

    ts-comments.enable = true;

    todo-comments = {
      enable = true;
      lazyLoad.settings.event = [
        "BufReadPost"
        "BufNewFile"
      ];
    };

    # ==========================================================================
    # Diagnostics (trouble.nvim)
    # ==========================================================================
    trouble = {
      enable = true;
      lazyLoad.settings.cmd = [ "Trouble" ];
      settings = {
        modes = {
          diagnostics = {
            auto_close = true;
            auto_preview = false;
          };
        };
      };
    };

    # ==========================================================================
    # Utilities
    # ==========================================================================
    which-key = {
      enable = true;
      lazyLoad.settings.event = [ "VeryLazy" ];
      settings = {
        delay = 200;
        icons.mappings = false;
      };
    };

    # ==========================================================================
    # Terminal
    # ==========================================================================
    toggleterm = {
      enable = true;
      lazyLoad.settings.cmd = [ "ToggleTerm" ];
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

    # ==========================================================================
    # Session management
    # ==========================================================================
    persistence = {
      enable = true;
      lazyLoad.settings.event = [ "BufReadPre" ];
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

    # ==========================================================================
    # AI: avante.nvim (Cursor-like AI with Claude)
    # ==========================================================================
    avante = {
      enable = true;
      lazyLoad.settings.cmd = [
        "AvanteAsk"
        "AvanteEdit"
        "AvanteToggle"
      ];
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
