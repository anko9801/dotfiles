{
  pkgs,
  lib,
  ...
}:

{
  home.packages = with pkgs; [
    # Languages - matching mise config
    nodejs_22 # Node.js LTS (was: node = "lts")
    python312 # Python (was: python = "latest")
    ruby_3_3 # Ruby (was: ruby = "latest")
    go # Go (was: go = "latest")
    rustup # Rust toolchain manager (was: rust = "latest")

    # Package managers
    pnpm # Fast npm alternative
    deno # JavaScript/TypeScript runtime
    bun # Fast JavaScript runtime
    lua # Lua scripting language
    uv # Fast Python package manager

    # Build tools
    gnumake
    cmake
    pkg-config

    # Language servers
    nodePackages.typescript-language-server
    pyright
    gopls
    # Note: rust-analyzer is provided by rustup

    # Additional dev tools
    ghq # Git repository manager
    # delta is installed via programs.delta in git.nix
    gitui # Git TUI
    gibo # .gitignore templates
    git-lfs # Git Large File Storage
    git-wt # Git worktree management

    # Cloud/DevOps (optional - uncomment if needed)
    # awscli2        # AWS CLI
    # terraform      # Infrastructure as code
    # kubectl        # Kubernetes CLI
    # kubernetes-helm # Helm
    # docker-compose # Docker Compose
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
