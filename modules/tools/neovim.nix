{
  pkgs,
  ...
}:

{
  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    # Colorscheme
    colorschemes.tokyonight = {
      enable = true;
      settings.style = "night";
    };

    # Global options
    opts = {
      # Line numbers
      number = true;
      relativenumber = true;

      # Tabs and indentation
      tabstop = 2;
      shiftwidth = 2;
      expandtab = true;
      smartindent = true;

      # Search
      ignorecase = true;
      smartcase = true;
      hlsearch = true;
      incsearch = true;

      # UI
      termguicolors = true;
      signcolumn = "yes";
      cursorline = true;
      scrolloff = 8;
      sidescrolloff = 8;
      list = true;
      listchars = {
        tab = "» ";
        trail = "·";
        nbsp = "␣";
      };

      # Behavior
      hidden = true;
      wrap = false;
      swapfile = false;
      backup = false;
      undofile = true;
      updatetime = 250;
      timeoutlen = 300;

      # Split
      splitbelow = true;
      splitright = true;

      # Clipboard
      clipboard = "unnamedplus";

      # Mouse
      mouse = "a";

      # Completion
      completeopt = "menuone,noselect,noinsert";
      pumheight = 10;

      # Fold (treesitter-based)
      foldmethod = "expr";
      foldexpr = "nvim_treesitter#foldexpr()";
      foldenable = false;
    };

    # Global variables
    globals = {
      mapleader = " ";
      maplocalleader = " ";
    };

    # Keymaps
    keymaps = [
      # Window navigation
      {
        mode = "n";
        key = "<C-h>";
        action = "<C-w>h";
        options.desc = "Move to left window";
      }
      {
        mode = "n";
        key = "<C-j>";
        action = "<C-w>j";
        options.desc = "Move to lower window";
      }
      {
        mode = "n";
        key = "<C-k>";
        action = "<C-w>k";
        options.desc = "Move to upper window";
      }
      {
        mode = "n";
        key = "<C-l>";
        action = "<C-w>l";
        options.desc = "Move to right window";
      }

      # Window resize
      {
        mode = "n";
        key = "<C-Up>";
        action = "<cmd>resize -2<CR>";
        options.desc = "Decrease window height";
      }
      {
        mode = "n";
        key = "<C-Down>";
        action = "<cmd>resize +2<CR>";
        options.desc = "Increase window height";
      }
      {
        mode = "n";
        key = "<C-Left>";
        action = "<cmd>vertical resize -2<CR>";
        options.desc = "Decrease window width";
      }
      {
        mode = "n";
        key = "<C-Right>";
        action = "<cmd>vertical resize +2<CR>";
        options.desc = "Increase window width";
      }

      # Clear search highlight
      {
        mode = "n";
        key = "<Esc>";
        action = "<cmd>nohlsearch<CR>";
        options.desc = "Clear search highlight";
      }

      # Better indenting
      {
        mode = "v";
        key = "<";
        action = "<gv";
      }
      {
        mode = "v";
        key = ">";
        action = ">gv";
      }

      # Move lines (normal mode)
      {
        mode = "n";
        key = "<A-j>";
        action = "<cmd>m .+1<CR>==";
        options.desc = "Move line down";
      }
      {
        mode = "n";
        key = "<A-k>";
        action = "<cmd>m .-2<CR>==";
        options.desc = "Move line up";
      }
      # Move lines (visual mode)
      {
        mode = "v";
        key = "<A-j>";
        action = ":m '>+1<CR>gv=gv";
        options.desc = "Move selection down";
      }
      {
        mode = "v";
        key = "<A-k>";
        action = ":m '<-2<CR>gv=gv";
        options.desc = "Move selection up";
      }
      {
        mode = "v";
        key = "J";
        action = ":m '>+1<CR>gv=gv";
        options.desc = "Move selection down";
      }
      {
        mode = "v";
        key = "K";
        action = ":m '<-2<CR>gv=gv";
        options.desc = "Move selection up";
      }

      # Buffer navigation
      {
        mode = "n";
        key = "<S-h>";
        action = "<cmd>bprevious<CR>";
        options.desc = "Previous buffer";
      }
      {
        mode = "n";
        key = "<S-l>";
        action = "<cmd>bnext<CR>";
        options.desc = "Next buffer";
      }

      # Save and quit
      {
        mode = "n";
        key = "<leader>w";
        action = "<cmd>w<CR>";
        options.desc = "Save file";
      }
      {
        mode = "n";
        key = "<leader>q";
        action = "<cmd>q<CR>";
        options.desc = "Quit";
      }
      {
        mode = "n";
        key = "<leader>Q";
        action = "<cmd>qa!<CR>";
        options.desc = "Quit all force";
      }

      # Split windows
      {
        mode = "n";
        key = "<leader>sv";
        action = "<C-w>v";
        options.desc = "Split window vertically";
      }
      {
        mode = "n";
        key = "<leader>sh";
        action = "<C-w>s";
        options.desc = "Split window horizontally";
      }
      {
        mode = "n";
        key = "<leader>se";
        action = "<C-w>=";
        options.desc = "Make splits equal size";
      }
      {
        mode = "n";
        key = "<leader>sx";
        action = "<cmd>close<CR>";
        options.desc = "Close current split";
      }

      # Tabs
      {
        mode = "n";
        key = "<leader>to";
        action = "<cmd>tabnew<CR>";
        options.desc = "Open new tab";
      }
      {
        mode = "n";
        key = "<leader>tx";
        action = "<cmd>tabclose<CR>";
        options.desc = "Close current tab";
      }
      {
        mode = "n";
        key = "<leader>tn";
        action = "<cmd>tabn<CR>";
        options.desc = "Go to next tab";
      }
      {
        mode = "n";
        key = "<leader>tp";
        action = "<cmd>tabp<CR>";
        options.desc = "Go to previous tab";
      }

      # Terminal
      {
        mode = "n";
        key = "<leader>tt";
        action = "<cmd>terminal<CR>";
        options.desc = "Open terminal";
      }
      {
        mode = "t";
        key = "<Esc><Esc>";
        action = "<C-\\><C-n>";
        options.desc = "Exit terminal mode";
      }

      # File explorer
      {
        mode = "n";
        key = "<leader>e";
        action = "<cmd>Neotree toggle<CR>";
        options.desc = "Toggle file explorer";
      }

      # Format
      {
        mode = "n";
        key = "<leader>cf";
        action = "<cmd>lua require('conform').format()<CR>";
        options.desc = "Format file";
      }
    ];

    # Plugins
    plugins = {
      # UI
      web-devicons.enable = true;

      lualine = {
        enable = true;
        settings = {
          options = {
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
                on_press.__raw = "function() require('telescope.builtin').find_files() end";
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
                on_press.__raw = "function() require('telescope.builtin').oldfiles() end";
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
                on_press.__raw = "function() require('telescope.builtin').live_grep() end";
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

      # File explorer
      neo-tree = {
        enable = true;
        settings.window.width = 30;
      };

      # Fuzzy finder
      telescope = {
        enable = true;
        extensions = {
          fzf-native.enable = true;
        };
        settings.defaults.mappings.i = {
          "<C-k>".__raw = "require('telescope.actions').move_selection_previous";
          "<C-j>".__raw = "require('telescope.actions').move_selection_next";
          "<C-q>".__raw =
            "require('telescope.actions').send_selected_to_qflist + require('telescope.actions').open_qflist";
        };
        keymaps = {
          "<leader>ff" = {
            action = "find_files";
            options.desc = "Find files";
          };
          "<leader>fg" = {
            action = "live_grep";
            options.desc = "Live grep";
          };
          "<leader>fb" = {
            action = "buffers";
            options.desc = "Buffers";
          };
          "<leader>fh" = {
            action = "help_tags";
            options.desc = "Help tags";
          };
          "<leader>fr" = {
            action = "oldfiles";
            options.desc = "Recent files";
          };
          "<leader>gc" = {
            action = "git_commits";
            options.desc = "Git commits";
          };
          "<leader>gs" = {
            action = "git_status";
            options.desc = "Git status";
          };
        };
      };

      # Treesitter
      treesitter = {
        enable = true;
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
      };

      # LSP
      lsp = {
        enable = true;
        servers = {
          lua_ls = {
            enable = true;
            settings = {
              Lua = {
                runtime.version = "LuaJIT";
                diagnostics.globals = [ "vim" ];
                workspace.checkThirdParty = false;
                telemetry.enable = false;
              };
            };
          };
          nil_ls.enable = true;
          ts_ls.enable = true;
          rust_analyzer = {
            enable = true;
            installCargo = false;
            installRustc = false;
          };
          pyright.enable = true;
          gopls.enable = true;
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
      fidget.enable = true;

      # Formatter
      conform-nvim = {
        enable = true;
        settings = {
          formatters_by_ft = {
            lua = [ "stylua" ];
            python = [
              "black"
              "isort"
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
            lsp_fallback = true;
          };
        };
      };

      # Completion
      cmp = {
        enable = true;
        autoEnableSources = true;
        settings = {
          sources = [
            { name = "nvim_lsp"; }
            { name = "luasnip"; }
            { name = "buffer"; }
            { name = "path"; }
          ];
          formatting.format.__raw = ''
            function(entry, vim_item)
              vim_item.menu = ({
                nvim_lsp = "[LSP]",
                luasnip = "[Snippet]",
                buffer = "[Buffer]",
                path = "[Path]",
              })[entry.source.name]
              return vim_item
            end
          '';
          mapping = {
            "<C-k>" = "cmp.mapping.select_prev_item()";
            "<C-j>" = "cmp.mapping.select_next_item()";
            "<C-b>" = "cmp.mapping.scroll_docs(-4)";
            "<C-f>" = "cmp.mapping.scroll_docs(4)";
            "<C-Space>" = "cmp.mapping.complete()";
            "<C-e>" = "cmp.mapping.abort()";
            "<CR>" = "cmp.mapping.confirm({ select = true })";
            "<Tab>" = "cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})";
            "<S-Tab>" = "cmp.mapping(cmp.mapping.select_prev_item(), {'i', 's'})";
          };
        };
      };

      # Snippets
      luasnip = {
        enable = true;
        fromVscode = [ { } ];
      };
      friendly-snippets.enable = true;

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

      # Auto pairs
      nvim-autopairs.enable = true;

      # Comments
      comment.enable = true;

      # Todo comments
      todo-comments.enable = true;

      # Surround
      nvim-surround.enable = true;

      # Which key
      which-key.enable = true;
    };

    # Extra packages
    extraPackages = with pkgs; [
      # Formatters
      stylua
      nixfmt
      prettierd
      black
      isort

      # Tools
      ripgrep
      fd
    ];
  };
}
