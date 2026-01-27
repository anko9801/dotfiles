{
  pkgs,
  ...
}:

{
  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    # Disable aliases to avoid conflict with vim
    viAlias = false;
    vimAlias = false;
    vimdiffAlias = false;

    # Performance: byte compilation
    performance.byteCompileLua = {
      enable = true;
      nvimRuntime = true;
      configs = true;
      plugins = true;
    };

    # Colorscheme
    colorschemes.tokyonight = {
      enable = true;
      settings = {
        style = "night";
        transparent = false;
        terminal_colors = true;
        styles = {
          comments = {
            italic = true;
          };
          keywords = {
            italic = true;
          };
          sidebars = "dark";
          floats = "dark";
        };
      };
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

      # Fold (native treesitter - Neovim 0.10+)
      foldmethod = "expr";
      foldexpr = "v:lua.vim.treesitter.foldexpr()";
      foldenable = false;
    };

    # Global variables
    globals = {
      mapleader = " ";
      maplocalleader = " ";
    };

    # Autocommands
    autoGroups = {
      YankHighlight.clear = true;
      TrimWhitespace.clear = true;
      AutoCreateDir.clear = true;
      LastLocation.clear = true;
      CloseWithQ.clear = true;
      WrapSpell.clear = true;
    };

    autoCmd = [
      # Highlight on yank
      {
        event = "TextYankPost";
        group = "YankHighlight";
        callback.__raw = ''
          function()
            vim.highlight.on_yank({ higroup = "IncSearch", timeout = 200 })
          end
        '';
      }
      # Remove trailing whitespace on save
      {
        event = "BufWritePre";
        group = "TrimWhitespace";
        pattern = "*";
        command = "%s/\\s\\+$//e";
      }
      # Auto create dir when saving a file
      {
        event = "BufWritePre";
        group = "AutoCreateDir";
        callback.__raw = ''
          function(event)
            if event.match:match("^%w%w+://") then
              return
            end
            local file = vim.loop.fs_realpath(event.match) or event.match
            vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
          end
        '';
      }
      # Go to last location when opening a buffer
      {
        event = "BufReadPost";
        group = "LastLocation";
        callback.__raw = ''
          function()
            local mark = vim.api.nvim_buf_get_mark(0, '"')
            local lcount = vim.api.nvim_buf_line_count(0)
            if mark[1] > 0 and mark[1] <= lcount then
              pcall(vim.api.nvim_win_set_cursor, 0, mark)
            end
          end
        '';
      }
      # Close some filetypes with <q>
      {
        event = "FileType";
        group = "CloseWithQ";
        pattern = [
          "help"
          "lspinfo"
          "man"
          "notify"
          "qf"
          "checkhealth"
          "oil"
        ];
        callback.__raw = ''
          function(event)
            vim.bo[event.buf].buflisted = false
            vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
          end
        '';
      }
      # Wrap and check for spell in text filetypes
      {
        event = "FileType";
        group = "WrapSpell";
        pattern = [
          "gitcommit"
          "markdown"
        ];
        callback.__raw = ''
          function()
            vim.opt_local.wrap = true
            vim.opt_local.spell = true
          end
        '';
      }
    ];

    # Keymaps
    keymaps = [
      # Better j/k navigation (wrapped lines)
      {
        mode = [ "n" "v" ];
        key = "j";
        action = "gj";
        options.silent = true;
      }
      {
        mode = [ "n" "v" ];
        key = "k";
        action = "gk";
        options.silent = true;
      }

      # Yank to end of line (consistent with D and C)
      {
        mode = "n";
        key = "Y";
        action = "y$";
      }

      # Keep cursor centered when searching
      {
        mode = "n";
        key = "n";
        action = "nzzzv";
        options.desc = "Next search result (centered)";
      }
      {
        mode = "n";
        key = "N";
        action = "Nzzzv";
        options.desc = "Previous search result (centered)";
      }

      # Keep cursor centered when joining lines
      {
        mode = "n";
        key = "J";
        action = "mzJ`z";
        options.desc = "Join lines (keep cursor)";
      }

      # Quick escape from insert mode
      {
        mode = "i";
        key = "jk";
        action = "<Esc>";
        options.desc = "Escape";
      }

      # QuickFix navigation
      {
        mode = "n";
        key = "]q";
        action = "<cmd>cnext<CR>zz";
        options.desc = "Next quickfix";
      }
      {
        mode = "n";
        key = "[q";
        action = "<cmd>cprevious<CR>zz";
        options.desc = "Previous quickfix";
      }
      {
        mode = "n";
        key = "<leader>xq";
        action = "<cmd>copen<CR>";
        options.desc = "Open quickfix";
      }

      # Command-line navigation (Emacs style)
      { mode = "c"; key = "<C-a>"; action = "<Home>"; }
      { mode = "c"; key = "<C-e>"; action = "<End>"; }
      { mode = "c"; key = "<C-b>"; action = "<Left>"; }
      { mode = "c"; key = "<C-f>"; action = "<Right>"; }

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
      { mode = "v"; key = "<"; action = "<gv"; }
      { mode = "v"; key = ">"; action = ">gv"; }

      # Move lines
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

      # File explorer (neo-tree)
      {
        mode = "n";
        key = "<leader>e";
        action = "<cmd>Neotree toggle<CR>";
        options.desc = "Toggle file explorer";
      }

      # Oil.nvim (edit filesystem like buffer)
      {
        mode = "n";
        key = "-";
        action = "<cmd>Oil<CR>";
        options.desc = "Open parent directory";
      }

      # Format
      {
        mode = "n";
        key = "<leader>cf";
        action = "<cmd>lua require('conform').format()<CR>";
        options.desc = "Format file";
      }

      # Lazygit
      {
        mode = "n";
        key = "<leader>gg";
        action.__raw = ''
          function()
            require("toggleterm.terminal").Terminal:new({
              cmd = "lazygit",
              dir = "git_dir",
              direction = "float",
              float_opts = { border = "double" },
            }):toggle()
          end
        '';
        options.desc = "Lazygit";
      }

      # Diffview
      {
        mode = "n";
        key = "<leader>gd";
        action = "<cmd>DiffviewOpen<CR>";
        options.desc = "Git diff";
      }
      {
        mode = "n";
        key = "<leader>gD";
        action = "<cmd>DiffviewClose<CR>";
        options.desc = "Close diff";
      }

      # Harpoon
      {
        mode = "n";
        key = "<leader>a";
        action.__raw = "function() require('harpoon'):list():add() end";
        options.desc = "Harpoon add file";
      }
      {
        mode = "n";
        key = "<leader>h";
        action.__raw = "function() require('harpoon').ui:toggle_quick_menu(require('harpoon'):list()) end";
        options.desc = "Harpoon menu";
      }
      {
        mode = "n";
        key = "<leader>1";
        action.__raw = "function() require('harpoon'):list():select(1) end";
        options.desc = "Harpoon file 1";
      }
      {
        mode = "n";
        key = "<leader>2";
        action.__raw = "function() require('harpoon'):list():select(2) end";
        options.desc = "Harpoon file 2";
      }
      {
        mode = "n";
        key = "<leader>3";
        action.__raw = "function() require('harpoon'):list():select(3) end";
        options.desc = "Harpoon file 3";
      }
      {
        mode = "n";
        key = "<leader>4";
        action.__raw = "function() require('harpoon'):list():select(4) end";
        options.desc = "Harpoon file 4";
      }

      # fzf-lua keymaps
      {
        mode = "n";
        key = "<leader>ff";
        action = "<cmd>FzfLua files<CR>";
        options.desc = "Find files";
      }
      {
        mode = "n";
        key = "<leader>fg";
        action = "<cmd>FzfLua live_grep<CR>";
        options.desc = "Live grep";
      }
      {
        mode = "n";
        key = "<leader>fb";
        action = "<cmd>FzfLua buffers<CR>";
        options.desc = "Buffers";
      }
      {
        mode = "n";
        key = "<leader>fh";
        action = "<cmd>FzfLua help_tags<CR>";
        options.desc = "Help tags";
      }
      {
        mode = "n";
        key = "<leader>fr";
        action = "<cmd>FzfLua oldfiles<CR>";
        options.desc = "Recent files";
      }
      {
        mode = "n";
        key = "<leader>gc";
        action = "<cmd>FzfLua git_commits<CR>";
        options.desc = "Git commits";
      }
      {
        mode = "n";
        key = "<leader>gs";
        action = "<cmd>FzfLua git_status<CR>";
        options.desc = "Git status";
      }

      # Flash keymaps
      {
        mode = [ "n" "x" "o" ];
        key = "s";
        action.__raw = "function() require('flash').jump() end";
        options.desc = "Flash jump";
      }
      {
        mode = [ "n" "x" "o" ];
        key = "S";
        action.__raw = "function() require('flash').treesitter() end";
        options.desc = "Flash treesitter";
      }
      {
        mode = "o";
        key = "r";
        action.__raw = "function() require('flash').remote() end";
        options.desc = "Flash remote";
      }
    ];

    # Plugins
    plugins = {
      # Lazy loading with lz.n
      lz-n.enable = true;

      # UI (load immediately)
      web-devicons.enable = true;

      lualine = {
        enable = true;
        settings.options = {
          theme = "tokyonight";
          component_separators = { left = ""; right = ""; };
          section_separators = { left = ""; right = ""; };
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
          indent = { char = "│"; tab_char = "│"; };
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
          { type = "padding"; val = 2; }
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
            opts = { position = "center"; hl = "Type"; };
          }
          { type = "padding"; val = 2; }
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

      # File explorer: neo-tree + oil.nvim
      neo-tree = {
        enable = true;
        lazyLoad.settings.cmd = [ "Neotree" ];
        settings = {
          window.width = 30;
          filesystem.filtered_items.visible = true;
        };
      };

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
        grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
          bash
          c
          cpp
          css
          diff
          dockerfile
          fish
          git_rebase
          gitcommit
          go
          gomod
          html
          javascript
          json
          lua
          luadoc
          make
          markdown
          markdown_inline
          nix
          python
          query
          regex
          rust
          sql
          toml
          tsx
          typescript
          vim
          vimdoc
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

      # LSP
      lsp = {
        enable = true;
        servers = {
          # Nix: nixd (preferred over nil_ls in 2025)
          # Provides full NixOS/Home Manager option completion
          nixd = {
            enable = true;
            settings.nixd = {
              nixpkgs.expr = "import (builtins.getFlake \"nixpkgs\") { }";
              formatting.command = [ "nixfmt" ];
              options = {
                home_manager.expr = ''(builtins.getFlake ("git+file://" + builtins.getEnv "HOME" + "/dotfiles")).homeConfigurations."anko@wsl".options'';
              };
            };
          };
          lua_ls = {
            enable = true;
            settings.Lua = {
              runtime.version = "LuaJIT";
              diagnostics.globals = [ "vim" ];
              workspace.checkThirdParty = false;
              telemetry.enable = false;
            };
          };
          ts_ls.enable = true;
          rust_analyzer = {
            enable = true;
            installCargo = false;
            installRustc = false;
            settings.rust-analyzer.check.command = "clippy";
          };
          basedpyright.enable = true;
          ruff.enable = true;
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
            python = [ "ruff_format" "ruff_organize_imports" ];
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
            default = [ "lsp" "path" "snippets" "buffer" ];
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
        lazyLoad.settings.cmd = [ "DiffviewOpen" "DiffviewFileHistory" ];
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
      ts-comments = {
        enable = true;
      };

      # Todo comments
      todo-comments = {
        enable = true;
        lazyLoad.settings.event = [ "BufReadPost" "BufNewFile" ];
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

    # Extra packages
    extraPackages = with pkgs; [
      # Formatters
      stylua
      nixfmt-rfc-style
      prettierd
      ruff

      # Linters
      statix
      eslint_d

      # Tools
      ripgrep
      fd
      fzf
      lazygit
      bat
    ];
  };
}
