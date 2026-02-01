{
  pkgs,
  config,
  ...
}:

{
  home = {
    packages = with pkgs; [
      # Modern CLI replacements
      ripgrep # grep replacement (rg)
      fd # find replacement
      sd # sed replacement
      dust # du replacement
      duf # df replacement
      bottom # top replacement (btm)
      procs # ps replacement

      # File operations
      tree
      jq # JSON processor
      yq-go # YAML processor

      # Networking
      curl
      wget
      xh # HTTP client (Rust, httpie-compatible)
      rsync # Fast incremental file transfer

      # Archives
      zip
      unzip
      p7zip

      # Text processing
      gawk
      gnused

      # Database
      sqlite # SQLite CLI

      # Misc
      watchexec # file watcher
      fzf-git-sh # Git + fzf integration (Ctrl-G Ctrl-F/B/T/H)

      # Markdown/Documentation
      glow # Markdown renderer for CLI

      # Data analysis
      jless # JSON viewer with expand/collapse
    ];

    sessionVariables = {
      RIPGREP_CONFIG_PATH = "${config.xdg.configHome}/ripgrep/config";
      _JQ_COLORS = "1;36:0;33:0;33:0;39:0;32:1;39:1;39";
    };

    # LaTeXmk configuration
    file.".latexmkrc".text = ''
      #!/usr/bin/env perl

      # LuaLaTeX (modern, Unicode native)
      $lualatex = "lualatex -file-line-error -synctex=1 -interaction=nonstopmode -halt-on-error --shell-escape %O %S";
      $pdf_mode = 4;
      $max_repeat = 5;

      # BibTeX / Biber
      $bibtex = "pbibtex %O %S";
      $biber = "biber --bblencoding=utf8 -u -U --output_safechars %O %S";

      # Index
      $makeindex = "mendex %O -o %D %S";

      # Preview (OS-specific)
      $pvc_view_file_via_temporary = 0;
      if ($^O eq 'linux') {
          $dvi_previewer = "xdg-open %S";
          $pdf_previewer = "xdg-open %S";
      } elsif ($^O eq 'darwin') {
          $dvi_previewer = "open %S";
          $pdf_previewer = "open %S";
      } else {
          $dvi_previewer = "start %S";
          $pdf_previewer = "start %S";
      }
    '';
  };

  xdg.configFile = {
    "ripgrep/config".text = ''
      --hidden
      --follow
      --smart-case
      --line-number
      --column
      --color=auto
      --glob=!.git/*
      --glob=!node_modules/*
      --glob=!.venv/*
      --glob=!__pycache__/*
      --glob=!target/*
      --glob=!dist/*
      --glob=!build/*
    '';

    "fd/ignore".text = ''
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
  };

  programs = {
    tealdeer = {
      enable = true;
      settings = {
        display = {
          compact = false;
          use_pager = true;
        };
        updates = {
          auto_update = true;
          auto_update_interval_hours = 720;
        };
      };
    };

    # yazi is in platforms/darwin.nix (heavy due to ffmpeg dependency)

    readline = {
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

    man = {
      enable = true;
      generateCaches = false; # Skip man page index rebuild (saves 30-60s)
    };

    eza = {
      enable = true;
      enableZshIntegration = true;
      icons = "auto";
      git = true;
    };

    htop = {
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

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    zoxide = {
      enable = true;
      enableZshIntegration = true;
      options = [
        "--cmd"
        "cd"
      ];
    };

    fzf = {
      enable = true;
      enableZshIntegration = true;
      defaultOptions = [
        "--height=40%"
        "--layout=reverse"
        "--border"
      ];
    };
  };
}
