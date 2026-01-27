{
  pkgs,
  ...
}:

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

    tmux = {
      enable = true;
      shell = "${pkgs.zsh}/bin/zsh";
      terminal = "screen-256color";
      prefix = "C-q";
      baseIndex = 1;
      historyLimit = 100000;
      mouse = true;
      keyMode = "vi";
      escapeTime = 0;
      plugins = with pkgs.tmuxPlugins; [
        sensible
        resurrect
        continuum
        yank
        open
        prefix-highlight
        cpu
        battery
      ];
      extraConfig = ''
        # Status bar
        set-option -g status-position top
        set-option -g status-left-length 90
        set-option -g status-right-length 90
        set-option -g status-left '#H:[#P]'
        set-option -g status-right '#{prefix_highlight} CPU: #{cpu_percentage} | Batt: #{battery_percentage} | [%Y-%m-%d(%a) %H:%M]'
        set-option -g status-interval 1
        set-option -g status-justify centre
        set-option -g status-bg "colour238"
        set-option -g status-fg "colour255"

        # Vim-tmux-navigator
        is_vim="ps -o state= -o comm= -t '#{pane_tty}' | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|n?vim?x?)(diff)?$'"
        bind-key -n 'C-h' if-shell "$is_vim" 'send-keys C-h' 'select-pane -L'
        bind-key -n 'C-j' if-shell "$is_vim" 'send-keys C-j' 'select-pane -D'
        bind-key -n 'C-k' if-shell "$is_vim" 'send-keys C-k' 'select-pane -U'
        bind-key -n 'C-l' if-shell "$is_vim" 'send-keys C-l' 'select-pane -R'

        # Vim-like pane navigation
        bind h select-pane -L
        bind j select-pane -D
        bind k select-pane -U
        bind l select-pane -R

        # Vim-like pane resize
        bind -r H resize-pane -L 5
        bind -r J resize-pane -D 5
        bind -r K resize-pane -U 5
        bind -r L resize-pane -R 5

        # Split panes
        bind | split-window -h
        bind - split-window -v

        # Mouse wheel scrolling
        bind -n WheelUpPane if-shell -F -t = "#{mouse_any_flag}" "send-keys -M" "if -Ft= '#{pane_in_mode}' 'send-keys -M' 'copy-mode -e'"

        # Paste
        bind-key C-p paste-buffer

        # Copy mode vi bindings
        bind-key -T copy-mode-vi v send -X begin-selection
        bind-key -T copy-mode-vi C-v send -X rectangle-toggle
        bind-key -T copy-mode-vi V send -X select-line
        bind-key -T copy-mode-vi Y send copy-line
        unbind -T copy-mode-vi Enter
        bind-key -T copy-mode-vi Escape send -X clear-selection
        bind-key -T copy-mode-vi C-c send -X cancel
        bind-key -T copy-mode-vi C-a send -X start-of-line
        bind-key -T copy-mode-vi C-e send -X end-of-line
        bind-key -T copy-mode-vi w send -X next-word
        bind-key -T copy-mode-vi e send -X next-word-end
        bind-key -T copy-mode-vi b send -X previous-word
        bind-key -T copy-mode-vi g send -X top-line
        bind-key -T copy-mode-vi G send -X bottom-line
        bind-key -T copy-mode-vi / send -X search-forward
        bind-key -T copy-mode-vi ? send -X search-backward
        bind-key -T copy-mode-vi C-b send -X page-up
        bind-key -T copy-mode-vi C-f send -X page-down
        bind-key -T copy-mode-vi C-u send -X scroll-up
        bind-key -T copy-mode-vi C-d send -X scroll-down

        # Plugin settings
        set -g @resurrect-capture-pane-contents 'on'
        set -g @resurrect-strategy-vim 'session'
        set -g @resurrect-strategy-nvim 'session'
        set -g @continuum-restore 'on'
        set -g @continuum-save-interval '15'
        set -g @yank_selection 'clipboard'
        set -g @yank_selection_mouse 'clipboard'
        set -g @prefix_highlight_fg 'white'
        set -g @prefix_highlight_bg 'blue'
        set -g @prefix_highlight_show_copy_mode 'on'
      '';
    };

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
