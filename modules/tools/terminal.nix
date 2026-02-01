_:

{
  programs = {
    atuin = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        search_mode = "fuzzy";
        filter_mode = "global";
        filter_mode_shell_up_key_binding = "session";
        show_preview = true;
        invert = false;
        exit_mode = "return-query";
        style = "auto";
        max_history_length = 10000;
        history_filter = [
          "^ls"
          "^cd"
          "^pwd"
          "^exit"
          "^history"
          "^clear"
        ];
        enter_accept = true;
        secrets_filter = true;
        show_help = false;
      };
    };

    bat = {
      enable = true;
      config = {
        theme = "TwoDark";
        style = "numbers,changes,header";
        pager = "less -FR";
      };
    };

    # tmux removed in favor of zellij (2025 optimization)

    zellij = {
      enable = true;
      # KDL config via xdg.configFile (keybinds not supported in settings)
    };
  };

  xdg.configFile = {
    "zellij/config.kdl".text = ''
      // ==============================================================================
      // Zellij Configuration - tmux-like keybindings
      // ==============================================================================

      // UI
      ui {
          pane_frames {
              rounded_corners true
              hide_session_name true
          }
      }

      // Options
      pane_frames false
      simplified_ui true
      mouse_mode true
      on_force_close "detach"
      scrollback_editor "nvim"
      copy_command "wl-copy"
      default_layout "default"

      // ==============================================================================
      // Keybindings - Ctrl-q prefix (avoids Ctrl-b conflict with shells)
      // Layer: Multiplexer (Super=WM, Ctrl=Editor, Ctrl-q=Multiplexer)
      // ==============================================================================
      keybinds clear-defaults=true {
          normal {
              bind "Ctrl q" { SwitchToMode "tmux"; }
          }

          tmux {
              // Pane: split
              bind "\"" { NewPane "Down"; SwitchToMode "Normal"; }
              bind "%" { NewPane "Right"; SwitchToMode "Normal"; }
              bind "-" { NewPane "Down"; SwitchToMode "Normal"; }
              bind "|" { NewPane "Right"; SwitchToMode "Normal"; }

              // Pane: close/zoom
              bind "x" { CloseFocus; SwitchToMode "Normal"; }
              bind "z" { ToggleFocusFullscreen; SwitchToMode "Normal"; }

              // Pane: navigate
              bind "h" "Left" { MoveFocus "Left"; SwitchToMode "Normal"; }
              bind "l" "Right" { MoveFocus "Right"; SwitchToMode "Normal"; }
              bind "j" "Down" { MoveFocus "Down"; SwitchToMode "Normal"; }
              bind "k" "Up" { MoveFocus "Up"; SwitchToMode "Normal"; }

              // Pane: resize
              bind "H" { Resize "Increase Left"; }
              bind "L" { Resize "Increase Right"; }
              bind "J" { Resize "Increase Down"; }
              bind "K" { Resize "Increase Up"; }

              // Tab
              bind "c" { NewTab; SwitchToMode "Normal"; }
              bind "n" { GoToNextTab; SwitchToMode "Normal"; }
              bind "p" { GoToPreviousTab; SwitchToMode "Normal"; }
              bind "1" { GoToTab 1; SwitchToMode "Normal"; }
              bind "2" { GoToTab 2; SwitchToMode "Normal"; }
              bind "3" { GoToTab 3; SwitchToMode "Normal"; }
              bind "4" { GoToTab 4; SwitchToMode "Normal"; }
              bind "5" { GoToTab 5; SwitchToMode "Normal"; }
              bind "," { SwitchToMode "RenameTab"; }

              // Session
              bind "d" { Detach; }
              bind "w" { SwitchToMode "Session"; }

              // Scroll
              bind "[" { SwitchToMode "Scroll"; }

              // Exit tmux mode
              bind "Ctrl q" "Esc" { SwitchToMode "Normal"; }
          }

          scroll {
              bind "j" "Down" { ScrollDown; }
              bind "k" "Up" { ScrollUp; }
              bind "Ctrl d" { HalfPageScrollDown; }
              bind "Ctrl u" { HalfPageScrollUp; }
              bind "g" { ScrollToTop; }
              bind "G" { ScrollToBottom; }
              bind "/" { SwitchToMode "EnterSearch"; SearchInput 0; }
              bind "q" "Esc" { SwitchToMode "Normal"; }
          }

          entersearch {
              bind "Enter" { SwitchToMode "Search"; }
              bind "Esc" { SwitchToMode "Scroll"; }
          }

          search {
              bind "n" { Search "down"; }
              bind "N" { Search "up"; }
              bind "Esc" { SwitchToMode "Scroll"; }
          }

          renametab {
              bind "Enter" { SwitchToMode "Normal"; }
              bind "Esc" { UndoRenameTab; SwitchToMode "Normal"; }
          }

          session {
              bind "d" { Detach; }
              bind "Esc" "Enter" { SwitchToMode "Normal"; }
          }

          // Alt+hjkl removed - reserved for editor (Neovim line movement)
          // Use Ctrl-q + hjkl for pane navigation instead
      }
      }
    '';

    "gitleaks/config.toml".text = ''
      title = "gitleaks config"

      [extend]
      useDefault = true

      [[rules]]
      id = "1password-secret-reference"
      description = "1Password secret reference"
      regex = '''op://[a-zA-Z0-9-_]+/[a-zA-Z0-9-_]+/[a-zA-Z0-9-_]+'''
      [rules.allowlist]
      description = "Allow 1Password references"
      regexes = [
          '''op://[a-zA-Z0-9-_]+/[a-zA-Z0-9-_]+/[a-zA-Z0-9-_]+'''
      ]

      [allowlist]
      description = "global allow list"
      paths = [
          '''\.gitleaks\.toml$''',
          '''\.gitleaksignore$''',
          '''(^|/)vendor/''',
          '''(^|/)node_modules/''',
          '''\.lock$''',
          '''\.md$''',
          '''\.txt$'''
      ]
      regexes = [
          '''(example|template|sample|test|demo)''',
          '''[A-Z_]+=(\$\{[A-Z_]+\}|<[^>]+>|TODO|CHANGEME|REPLACE_ME|your-.*-here)''',
          '''(localhost|127\.0\.0\.1|0\.0\.0\.0|example\.com)'''
      ]
    '';
  };
}
