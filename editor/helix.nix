# Helix - A post-modern modal text editor
# https://helix-editor.com/
_:

{
  programs.helix = {
    enable = true;
    defaultEditor = false; # Keep nvim as default

    settings = {
      # Theme managed by stylix

      editor = {
        # Line numbers
        line-number = "relative";
        cursorline = true;
        color-modes = true;

        # Cursor
        cursor-shape = {
          insert = "bar";
          normal = "block";
          select = "underline";
        };

        # UI
        true-color = true;
        bufferline = "multiple";
        statusline = {
          left = [
            "mode"
            "spinner"
            "file-name"
            "file-modification-indicator"
          ];
          center = [ ];
          right = [
            "diagnostics"
            "selections"
            "register"
            "position"
            "file-encoding"
          ];
        };

        # Indentation
        indent-guides = {
          render = true;
          character = "│";
        };

        # Whitespace
        whitespace.render = {
          space = "none";
          tab = "all";
          newline = "none";
        };

        # File picker
        file-picker = {
          hidden = false;
          git-ignore = true;
        };

        # LSP
        lsp = {
          display-messages = true;
          display-inlay-hints = true;
        };

        # Soft wrap
        soft-wrap.enable = true;

        # Auto-save
        auto-save = {
          focus-lost = true;
          after-delay.enable = false;
        };

        # Auto-format on save
        auto-format = true;

        # Mouse support
        mouse = true;

        # Scroll offset
        scrolloff = 8;

        # Shell
        shell = [
          "zsh"
          "-c"
        ];
      };

      keys = {
        normal = {
          # Window navigation (match nvim)
          "C-h" = "jump_view_left";
          "C-j" = "jump_view_down";
          "C-k" = "jump_view_up";
          "C-l" = "jump_view_right";

          # Buffer navigation
          "H" = "goto_previous_buffer";
          "L" = "goto_next_buffer";

          # Quick save/quit
          "C-s" = ":w";
          "C-q" = ":q";

          # Center after jump
          "n" = [
            "search_next"
            "align_view_center"
          ];
          "N" = [
            "search_prev"
            "align_view_center"
          ];

          # File picker
          "space" = {
            "f" = "file_picker";
            "b" = "buffer_picker";
            "s" = "symbol_picker";
            "S" = "workspace_symbol_picker";
            "d" = "diagnostics_picker";
            "g" = "changed_file_picker";
            "/" = "global_search";

            # LSP
            "a" = "code_action";
            "r" = "rename_symbol";
            "h" = "hover";

            # Window management
            "w" = {
              "v" = "vsplit";
              "s" = "hsplit";
              "q" = ":quit";
            };
          };

          # Goto
          "g" = {
            "d" = "goto_definition";
            "D" = "goto_declaration";
            "y" = "goto_type_definition";
            "r" = "goto_reference";
            "i" = "goto_implementation";
          };

          # Diagnostics
          "]" = {
            "d" = "goto_next_diag";
            "e" = "goto_next_diag";
          };
          "[" = {
            "d" = "goto_prev_diag";
            "e" = "goto_prev_diag";
          };
        };

        insert = {
          # Escape alternatives
          "j" = {
            "k" = "normal_mode";
          };
        };
      };
    };

    languages = {
      language-server = {
        typescript-language-server = {
          command = "typescript-language-server";
          args = [ "--stdio" ];
        };
        rust-analyzer = {
          command = "rust-analyzer";
        };
        pylsp = {
          command = "pylsp";
        };
        nil = {
          command = "nil";
        };
        gopls = {
          command = "gopls";
        };
      };

      language = [
        {
          name = "typescript";
          auto-format = true;
          formatter = {
            command = "prettier";
            args = [
              "--parser"
              "typescript"
            ];
          };
        }
        {
          name = "javascript";
          auto-format = true;
          formatter = {
            command = "prettier";
            args = [
              "--parser"
              "babel"
            ];
          };
        }
        {
          name = "json";
          auto-format = true;
          formatter = {
            command = "prettier";
            args = [
              "--parser"
              "json"
            ];
          };
        }
        {
          name = "nix";
          auto-format = true;
          formatter.command = "nixfmt";
        }
        {
          name = "python";
          auto-format = true;
          formatter.command = "ruff";
          formatter.args = [
            "format"
            "-"
          ];
        }
        {
          name = "rust";
          auto-format = true;
        }
        {
          name = "go";
          auto-format = true;
          formatter.command = "gofmt";
        }
        {
          name = "markdown";
          auto-format = true;
          soft-wrap.enable = true;
        }
      ];
    };
  };
}
