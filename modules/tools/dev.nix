{
  pkgs,
  lib,
  ...
}:

{
  home = {
    packages = with pkgs; [
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
      # gdb - Not available on macOS, use lldb instead
      nasm # Assembler

      # Language servers (shared with neovim via PATH)
      gopls
      lua-language-server
      nodePackages.typescript-language-server
      pyright
      nixd

      # Additional dev tools
      ghq # Git repository manager
      # delta is installed via programs.delta in git.nix
      # lazygit is installed via programs.lazygit below
      gibo # .gitignore templates
      git-lfs # Git Large File Storage
      git-wt # Git worktree management

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
    ];

    activation = {
      setupRust = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        if command -v rustup &>/dev/null; then
          if ! rustup show active-toolchain &>/dev/null; then
            $DRY_RUN_CMD rustup default stable 2>/dev/null || true
          fi
        fi
      '';
    };

    # GDB configuration with exploit development frameworks
    file.".gdbinit".text = ''
      # PEDA - Python Exploit Development Assistance
      define init-peda
      source ~/peda/peda.py
      end
      document init-peda
      Initializes the PEDA framework
      end

      define init-peda-arm
      source ~/peda-arm/peda-arm.py
      end
      document init-peda-arm
      Initializes PEDA for ARM
      end

      define init-peda-intel
      source ~/peda-arm/peda-intel.py
      end
      document init-peda-intel
      Initializes PEDA for Intel
      end

      # PwnDBG
      define init-pwndbg
      source ~/pwndbg/gdbinit.py
      end
      document init-pwndbg
      Initializes PwnDBG
      end

      # GEF - GDB Enhanced Features
      define init-gef
      source ~/gef/gef.py
      end
      document init-gef
      Initializes GEF
      end
    '';
  };

  # ghq configuration
  xdg.configFile."ghq/config".text = ''
    [general]
    root = ["~/repos", "~/go/src"]
    default_root = "~/repos"

    [vcs]
    git = { protocol = "ssh" }
  '';

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
        # Environment variables set in home.nix sessionVariables
        env = { };
        tools = {
          # Runtimes - LTS/stable versions to avoid constant re-downloads
          node = "22";
          python = "latest";
          ruby = "latest";
          go = "latest";
          deno = "latest";
          bun = "latest";
          lua = "latest";
          java = "openjdk-21";
          pnpm = "10.28.1";
          # npm tools (version-pinned to avoid timeout issues)
          "npm:@antfu/ni" = "28.2.0";
          "npm:@google/gemini-cli" = "0.25.2";
          "npm:czg" = "1.12.0";
          "npm:cz-git" = "1.12.0";
          "npm:ccmanager" = "3.6.1";
          "npm:zenn-cli" = "0.4.3";
          "npm:gitmoji-cli" = "9.7.0";
          # claude-code is managed by Nix (programs.claude-code)
        };
        tasks = {
          update = {
            description = "Update all tools to latest versions";
            run = ''
              echo "📦 Updating mise tools..."
              mise update
              mise prune
              echo "✅ All tools updated!"
            '';
          };
          doctor = {
            description = "Check mise configuration and health";
            run = ''
              mise doctor
              echo "---"
              mise list
            '';
          };
          clean = {
            description = "Clean up old tool versions";
            run = ''
              echo "🧹 Cleaning up old versions..."
              mise prune --yes
              echo "✅ Cleanup complete!"
            '';
          };
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

    # Cargo configuration (HM news 2025-11-26)
    cargo = {
      enable = true;
      settings = {
        build = {
          jobs = 4;
        };
        net = {
          git-fetch-with-cli = true;
        };
      };
    };

    # npm configuration (HM news 2025-12-05)
    npm = {
      enable = true;
      settings = {
        prefix = "~/.npm-global";
        fund = false;
        audit = false;
      };
    };
  };
}
