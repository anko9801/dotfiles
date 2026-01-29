{
  pkgs,
  lib,
  ...
}:

{
  home.packages = with pkgs; [
    # Rust toolchain manager (special case - needs rustup for toolchain management)
    rustup

    # Package managers (Nix-managed for stability)
    uv # Fast Python package manager

    # AI tools
    # claude-code is managed via programs.claude-code in claude.nix

    # Build tools
    gnumake
    cmake
    ninja # Fast build system
    pkg-config
    autoconf
    automake
    libtool

    # Debug/Low-level tools
    gdb # GNU Debugger
    nasm # Assembler

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
    act # Run GitHub Actions locally

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

    # CLI tools (migrated from cargo)
    just # Task runner
    typst # Document processor
    ast-grep # Structural code search
    cargo-watch # Watch and rebuild
    wasm-pack # WebAssembly bundler
    wasm-tools # WebAssembly utilities
    sqlx-cli # SQL toolkit
  ];

  # act configuration (GitHub Actions local runner)
  xdg.configFile."act/actrc".text = ''
    -P ubuntu-latest=catthehacker/ubuntu:act-latest
    -P ubuntu-22.04=catthehacker/ubuntu:act-22.04
    -P ubuntu-20.04=catthehacker/ubuntu:act-20.04
    -P ubuntu-18.04=catthehacker/ubuntu:act-18.04
  '';

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

  programs = {
    # mise - polyglot tool version manager
    # Runtimes are managed by mise for latest versions
    mise = {
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
          "npm:gitmoji-cli" = "latest";
        };
      };
    };

    # GitHub CLI
    gh = {
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
    lazygit = {
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
  };
}
