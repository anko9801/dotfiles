{
  pkgs,
  lib,
  ...
}:

{
  # mise - polyglot tool version manager
  # Runtimes are managed by mise for latest versions
  programs.mise = {
    enable = true;
    enableZshIntegration = true;
    globalConfig = {
      settings = {
        experimental = true;
        legacy_version_file = true;
        jobs = 4;
        task_output = "prefix";
      };
      tools = {
        # Runtimes - managed by mise for latest versions
        node = "latest";
        python = "latest";
        go = "latest";
        deno = "latest";
        bun = "latest";
        java = "openjdk-21";
        # npm tools
        "npm:@antfu/ni" = "latest";
        "npm:pnpm" = "latest";
        "npm:yarn" = "latest";
        "npm:zenn-cli" = "latest";
      };
    };
  };

  home.packages = with pkgs; [
    # Rust toolchain manager (special case - needs rustup for toolchain management)
    rustup

    # Package managers (Nix-managed for stability)
    uv # Fast Python package manager

    # AI tools
    claude-code # Claude CLI

    # Build tools
    gnumake
    cmake
    pkg-config

    # Language servers
    nodePackages.typescript-language-server
    pyright
    gopls
    lua-language-server
    # Note: rust-analyzer is provided by rustup

    # Additional dev tools
    ghq # Git repository manager
    # delta is installed via programs.delta in git.nix
    gitui # Git TUI
    gibo # .gitignore templates
    git-lfs # Git Large File Storage
    git-wt # Git worktree management

    # gRPC/Protobuf tools
    buf # Protobuf tooling
    grpcurl # gRPC CLI
    protobuf # protoc compiler

    # Infrastructure tools
    terraform # Infrastructure as code
    ansible # Configuration management

    # Nix development tools
    nix-tree # Interactive dependency browser
    nix-du # Store space visualization
    manix # NixOS/HM option search
    nix-diff # Compare Nix derivations
    nvd # Nix version diff (compare closures)
    devenv # Per-project development environments

    # Secrets management
    sops # Secrets OPerationS
    age # Modern encryption tool
  ];

  # GitHub CLI
  programs.gh = {
    enable = true;
    settings = {
      git_protocol = "ssh";
      prompt = "enabled";
      aliases = {
        co = "pr checkout";
        pv = "pr view";
        pc = "pr create";
        pm = "pr merge";
        il = "issue list";
        ic = "issue create";
        iv = "issue view";
      };
    };
  };

  # Lazygit - Terminal UI for git
  programs.lazygit = {
    enable = true;
    settings = {
      gui = {
        showIcons = true;
        theme = {
          lightTheme = false;
          activeBorderColor = [
            "green"
            "bold"
          ];
          inactiveBorderColor = [ "white" ];
          selectedLineBgColor = [ "reverse" ];
        };
      };
      git = {
        paging = {
          colorArg = "always";
          pager = "delta --dark --paging=never";
        };
        commit = {
          signOff = false;
        };
        merging = {
          manualCommit = false;
          args = "";
        };
      };
      keybinding = {
        universal = {
          quit = "q";
          quit-alt1 = "<c-c>";
        };
      };
      os = {
        editPreset = "nvim";
      };
    };
  };

  # ghq configuration
  xdg.configFile."ghq/config".text = ''
    [general]
    root = ["~/repos", "~/go/src"]
    default_root = "~/repos"

    [vcs]
    git = { protocol = "ssh" }
  '';

  # Setup rustup on first activation
  home.activation = {
    setupRust = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if command -v rustup &>/dev/null; then
        if ! rustup show active-toolchain &>/dev/null; then
          $DRY_RUN_CMD rustup default stable 2>/dev/null || true
        fi
      fi
    '';
  };
}
