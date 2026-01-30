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
      settings = {
        ui.pane_frames = {
          rounded_corners = true;
          hide_session_name = false;
        };
        default_layout = "default";
        pane_frames = true;
        mouse_mode = true;
        on_force_close = "detach";
      };
    };
  };

  xdg.configFile = {
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
