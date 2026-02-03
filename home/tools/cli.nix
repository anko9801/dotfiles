{
  pkgs,
  lib,
  config,
  ...
}:

{
  home = {
    packages =
      with pkgs;
      [
        # Search & replace
        ripgrep # rg: fast grep
        fd # find alternative
        sd # sed alternative (simpler syntax)
        ast-grep # structural code search

        # File & disk info
        dust # du alternative (visual)
        duf # df alternative (visual)
        tree # directory tree
        ouch # universal archive tool (compress/decompress)

        # Process monitoring
        bottom # btm: top/htop alternative
        procs # ps alternative

        # Data processing
        jq # JSON processor
        jless # JSON viewer
        dasel # universal data selector (JSON/YAML/TOML/XML)
        dyff # YAML/JSON diff tool (semantic diff)
        yq-go # YAML processor (like jq for YAML)

        # Network
        curl # HTTP client
        wget # HTTP downloader
        xh # httpie alternative (colored output)
        nmap # network scanner

        # Container tools
        dive # Docker image layer explorer
        lazydocker # Docker TUI (manage containers/images/volumes)
        k9s # Kubernetes TUI

        # Load testing
        oha # Lightweight HTTP load generator (Rust)

        # File transfer & archive
        rsync # incremental file sync
        zip
        unzip
        p7zip # 7z

        # Text processing (POSIX compatibility)
        gawk # GNU awk
        gnused # GNU sed

        # Other
        sqlite # embedded database
        watchexec # file watcher (run command on change)
        glow # terminal markdown renderer
        typst # modern LaTeX alternative

        # Linters
        yamllint
        markdownlint-cli
      ]
      ++ lib.optionals pkgs.stdenv.isLinux [
        trashy # rm alternative (move to trash)
      ];

    sessionVariables = {
      PAGER = "less";
      LESSHISTFILE = "-";
      RIPGREP_CONFIG_PATH = "${config.xdg.configHome}/ripgrep/config";
      _JQ_COLORS = "1;36:0;33:0;33:0;39:0;32:1;39:1;39";
    };

    file.".latexmkrc".text = ''
      #!/usr/bin/env perl
      $lualatex = "lualatex -file-line-error -synctex=1 -interaction=nonstopmode -halt-on-error --shell-escape %O %S";
      $pdf_mode = 4;
      $max_repeat = 5;
      $bibtex = "pbibtex %O %S";
      $biber = "biber --bblencoding=utf8 -u -U --output_safechars %O %S";
      $makeindex = "mendex %O -o %D %S";
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

    man = {
      enable = true;
      generateCaches = false; # Speeds up rebuild; use `man -k` for search
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
  };
}
