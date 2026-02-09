{
  pkgs,
  lib,
  config,
  ...
}:

let
  isWorkstation = config.platform.isDarwin || config.platform.isWSL || config.platform.isLinuxDesktop;
in
{
  home = {
    packages =
      with pkgs;
      [
        # Essential (always installed)
        ripgrep # rg: fast grep
        fd # find alternative
        jq # JSON processor
        curl # HTTP client
        wget # HTTP downloader
        tree # directory tree
        htop # process monitor
        rsync # incremental file sync
        zip
        unzip
        p7zip # 7z
        gawk # GNU awk
        gnused # GNU sed
        netcat # network utility
        dig # DNS lookup
      ]
      ++ lib.optionals isWorkstation [
        # Workstation extras
        sd # sed alternative (simpler syntax)
        ast-grep # structural code search

        # Fancy alternatives
        dust # du alternative (visual)
        duf # df alternative (visual)
        ouch # universal archive tool
        bottom # btm: top/htop alternative
        procs # ps alternative

        # Data processing
        jless # JSON viewer
        dasel # universal data selector
        dyff # YAML/JSON diff tool
        yq-go # YAML processor

        # Network extras
        xh # httpie alternative
        nmap # network scanner

        # Container tools
        dive # Docker image layer explorer
        lazydocker # Docker TUI
        k9s # Kubernetes TUI

        # Load testing
        oha # HTTP load generator

        # Dev tools
        sqlite # embedded database
        watchexec # file watcher

        # Document tools
        glow # terminal markdown renderer
        typst # modern LaTeX alternative

        # Linters
        yamllint
        markdownlint-cli
      ]
      ++ lib.optionals config.platform.isLinux [
        trashy # rm alternative (move to trash)
      ]
      ++ lib.optionals config.platform.isWSL [
        wslu # WSL utilities (wslview, etc.)
      ]
      ++ lib.optionals config.platform.isLinuxDesktop [
        xdg-utils
        xclip
        wl-clipboard
      ]
      ++ lib.optionals config.platform.isDarwin [
        # GNU coreutils (macOS ships BSD versions)
        coreutils
        findutils
        gnugrep
        gnutar
        # macOS utilities
        darwin.trash # trash command
        terminal-notifier # notifications
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
      enable = isWorkstation;
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
