{
  config,
  pkgs,
  lib,
  ...
}:

{
  home.packages = with pkgs; [
    # Modern CLI replacements
    ripgrep # grep replacement (rg)
    fd # find replacement
    eza # ls replacement
    sd # sed replacement
    dust # du replacement
    duf # df replacement
    bottom # top replacement (btm)
    procs # ps replacement
    tokei # code statistics
    hyperfine # benchmarking tool

    # File operations
    tree
    jq # JSON processor
    yq-go # YAML processor
    hexyl # hex viewer

    # Networking
    curl
    wget
    httpie # HTTP client

    # Archives
    unzip
    p7zip

    # Text processing
    gawk
    gnused

    # Documentation
    tealdeer # tldr - simplified man pages
    man-db # man pages

    # Media
    ffmpeg # video/audio processing
    imagemagick # image processing
    yt-dlp # video downloader
    pandoc # document converter

    # Misc
    yadm # dotfiles manager
    watchexec # file watcher
    entr # run commands on file changes
    gomi # trash command (safer rm)
    mcfly # shell history search
  ];

  # Tealdeer (tldr) - simplified man pages
  programs.tealdeer = {
    enable = true;
    settings = {
      display = {
        compact = false;
        use_pager = true;
      };
      updates = {
        auto_update = true;
        auto_update_interval_hours = 720; # 30 days
      };
    };
  };

  # Yazi - terminal file manager
  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      manager = {
        show_hidden = true;
        sort_by = "natural";
        sort_dir_first = true;
      };
    };
  };

  # Readline configuration
  programs.readline = {
    enable = true;
    variables = {
      editing-mode = "vi";
      show-mode-in-prompt = true;
      vi-ins-mode-string = "\\1\\e[6 q\\2";
      vi-cmd-mode-string = "\\1\\e[2 q\\2";
      bell-style = "none";
      completion-ignore-case = true;
      completion-map-case = true;
      show-all-if-ambiguous = true;
      mark-symlinked-directories = true;
      colored-stats = true;
      visible-stats = true;
    };
  };

  # Man pages
  programs.man = {
    enable = true;
    generateCaches = true;
  };

  # eza (ls replacement) configuration
  programs.eza = {
    enable = true;
    enableZshIntegration = true;
    icons = "auto";
    git = true;
  };

  # htop - system monitoring
  programs.htop = {
    enable = true;
    settings = {
      show_program_path = false;
      highlight_base_name = true;
      hide_kernel_threads = true;
      hide_userland_threads = true;
      tree_view = true;
      header_margin = false;
      column_meters_0 = "LeftCPUs Memory Swap";
      column_meters_1 = "RightCPUs Tasks LoadAverage Uptime";
    };
  };

  # ripgrep configuration
  xdg.configFile."ripgrep/config".text = ''
    # Search hidden files by default
    --hidden
    # Follow symlinks
    --follow
    # Smart case (case-insensitive unless uppercase is used)
    --smart-case
    # Show line numbers
    --line-number
    # Show column numbers
    --column
    # Add colors
    --color=auto
    # Ignore common directories
    --glob=!.git/*
    --glob=!node_modules/*
    --glob=!.venv/*
    --glob=!__pycache__/*
    --glob=!target/*
    --glob=!dist/*
    --glob=!build/*
  '';

  # Set RIPGREP_CONFIG_PATH
  home.sessionVariables = {
    RIPGREP_CONFIG_PATH = "$XDG_CONFIG_HOME/ripgrep/config";
  };

  # fd configuration
  xdg.configFile."fd/ignore".text = ''
    .git/
    node_modules/
    .venv/
    __pycache__/
    target/
    dist/
    build/
    *.pyc
    *.pyo
    .DS_Store
    .cache/
  '';

  # jq colors
  home.sessionVariables._JQ_COLORS = "1;36:0;33:0;33:0;39:0;32:1;39:1;39";
}
