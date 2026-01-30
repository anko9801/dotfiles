{
  pkgs,
  ...
}:

{
  programs.nixvim.plugins = {
    # Lazy loading with lz.n
    lz-n.enable = true;

    # UI (load immediately)
    web-devicons.enable = true;

    lualine = {
      enable = true;
      settings.options = {
        theme = "tokyonight";
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

    bufferline = {
      enable = true;
      settings.options = {
        diagnostics = "nvim_lsp";
        show_buffer_close_icons = true;
        show_close_icon = true;
        separator_style = "slant";
      };
    };

    indent-blankline = {
      enable = true;
      settings = {
        indent = {
          char = "│";
          tab_char = "│";
        };
        scope.enabled = false;
      };
    };

    noice.enable = true;
    notify.enable = true;

    # Dashboard
    alpha = {
      enable = true;
      theme = null;
      settings.layout = [
        {
          type = "padding";
          val = 2;
        }
        {
          type = "text";
          val = [
            "                                                     "
            "  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗"
            "  ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║"
            "  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║"
            "  ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║"
            "  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║"
            "  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝"
            "                                                     "
          ];
          opts = {
            position = "center";
            hl = "Type";
          };
        }
        {
          type = "padding";
          val = 2;
        }
        {
          type = "group";
          val = [
            {
              type = "button";
              val = "  Find file";
              on_press.__raw = "function() vim.cmd('FzfLua files') end";
              opts = {
                shortcut = "f";
                position = "center";
                cursor = 3;
                width = 50;
                align_shortcut = "right";
                hl_shortcut = "Keyword";
              };
            }
            {
              type = "button";
              val = "  New file";
              on_press.__raw = "function() vim.cmd('ene | startinsert') end";
              opts = {
                shortcut = "e";
                position = "center";
                cursor = 3;
                width = 50;
                align_shortcut = "right";
                hl_shortcut = "Keyword";
              };
            }
            {
              type = "button";
              val = "  Recent files";
              on_press.__raw = "function() vim.cmd('FzfLua oldfiles') end";
              opts = {
                shortcut = "r";
                position = "center";
                cursor = 3;
                width = 50;
                align_shortcut = "right";
                hl_shortcut = "Keyword";
              };
            }
            {
              type = "button";
              val = "  Find text";
              on_press.__raw = "function() vim.cmd('FzfLua live_grep') end";
              opts = {
                shortcut = "t";
                position = "center";
                cursor = 3;
                width = 50;
                align_shortcut = "right";
                hl_shortcut = "Keyword";
              };
            }
            {
              type = "button";
              val = "  Quit";
              on_press.__raw = "function() vim.cmd('qa') end";
              opts = {
                shortcut = "q";
                position = "center";
                cursor = 3;
                width = 50;
                align_shortcut = "right";
                hl_shortcut = "Keyword";
              };
            }
          ];
        }
      ];
    };

    # File explorer: oil.nvim (lightweight, buffer-based)
    oil = {
      enable = true;
      lazyLoad.settings.cmd = [ "Oil" ];
      settings = {
        view_options.show_hidden = true;
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

    # Fuzzy finder: fzf-lua (faster than telescope)
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
        };
        files = {
          fd_opts = "--type f --hidden --follow --exclude .git";
        };
        grep = {
          rg_opts = "--column --line-number --no-heading --color=always --smart-case";
        };
      };
    };

    # Motion: flash.nvim (better than leap/hop)
    flash = {
      enable = true;
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

    # Harpoon: quick file navigation
    harpoon = {
      enable = true;
      enableTelescope = false;
    };

    # Treesitter with explicit grammars (required for NixOS)
    treesitter = {
      enable = true;
      nixvimInjections = true;
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
      # Essential grammars only (removed: diff, fish, git_rebase, gitcommit, luadoc, make, query, regex, vim, vimdoc)
      grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
        bash
        c
        cpp
        css
        dockerfile
        go
        gomod
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
        tsx
        typescript
        yaml
      ];
    };

    # Treesitter extensions
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
      settings.max_lines = 3;
    };

    ts-autotag.enable = true;
    rainbow-delimiters.enable = true;

    # Git
    gitsigns = {
      enable = true;
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

            -- Navigation
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

            -- Actions
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

    # Git conflict resolution
    git-conflict = {
      enable = true;
      settings.default_mappings = true;
    };

    # Auto pairs
    nvim-autopairs = {
      enable = true;
      lazyLoad.settings.event = [ "InsertEnter" ];
    };

    # Comments: use ts-comments for proper treesitter detection
    # (Neovim 0.10+ has native gc/gcc, ts-comments adds commentstring)
    ts-comments.enable = true;

    # Todo comments
    todo-comments = {
      enable = true;
      lazyLoad.settings.event = [
        "BufReadPost"
        "BufNewFile"
      ];
    };

    # Surround
    nvim-surround = {
      enable = true;
      lazyLoad.settings.event = [ "VeryLazy" ];
    };

    # Which key
    which-key = {
      enable = true;
      settings.delay = 200;
    };

    # Terminal
    toggleterm = {
      enable = true;
      lazyLoad.settings.cmd = [ "ToggleTerm" ];
      settings = {
        size = 20;
        open_mapping.__raw = "[[<c-\\>]]";
        hide_numbers = true;
        shade_terminals = true;
        shading_factor = 2;
        start_in_insert = true;
        insert_mappings = true;
        persist_size = true;
        direction = "float";
        close_on_exit = true;
        float_opts.border = "curved";
      };
    };
  };
}
