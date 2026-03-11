# Development tools configuration (pre-commit, treefmt, devShell)
# flake-parts module
_: {
  perSystem =
    { config, pkgs, ... }:
    {
      # Pre-commit hooks
      pre-commit = {
        check.enable = true;
        settings.hooks = {
          treefmt = {
            enable = true;
            package = config.treefmt.build.wrapper;
          };
          deadnix.enable = true;
          statix.enable = true;
        };
      };

      # Treefmt with extended formatters
      treefmt = {
        projectRootFile = "flake.nix";
        programs = {
          nixfmt.enable = true;
          shfmt.enable = true;
          yamlfmt.enable = true;
        };
        settings = {
          global.excludes = [
            ".git/**"
            "*.lock"
          ];
          formatter = {
            fish-indent = {
              command = "${pkgs.fish}/bin/fish_indent";
              options = [ "--write" ];
              includes = [ "*.fish" ];
            };
            gitleaks = {
              command = "${pkgs.gitleaks}/bin/gitleaks";
              options = [
                "detect"
                "--no-git"
                "--exit-code"
                "0"
              ];
              priority = 99;
              includes = [ "*" ];
              excludes = [
                "*.png"
                "*.jpg"
                "*.gif"
                "node_modules/**"
                ".direnv/**"
              ];
            };
          };
        };
      };

      # Spell checking via nix flake check (docs only)
      cspell = {
        check =
          projectRoot:
          pkgs.runCommand "cspell-check" { nativeBuildInputs = [ config.cspell.package ]; } ''
            cd ${projectRoot}
            cspell --config ${config.cspell.configFile} "docs/**/*.md"
            touch $out
          '';
        settings = {
          words = [
            # Nix ecosystem
            "nixpkgs"
            "nixvim"
            "nix-darwin"
            "dotfiles"
            "homebrew"
            "stylix"
            "catppuccin"
            "devenv"
            "direnv"
            "treefmt"
            "nixfmt"
            "cachix"
            "neovim"
            "nvim"
            # Tools
            "ghostty"
            "zellij"
            "sketchybar"
            "kanata"
            "atuin"
            "zoxide"
            "starship"
            "aerospace"
            "komorebi"
            "yazi"
            "difftastic"
            "gitui"
            "gitu"
            "lazyworktree"
            "worktree"
            "zdiff"
            "zinit"
            "sxhkd"
            "xcape"
            "xremap"
            "chezmoi"
            "yadm"
            "Karabiner"
            "bspwm"
            # Keyboard/keybinding terms
            "keybinds"
            "keymap"
            "keymaps"
            "keymapping"
            "keypresses"
            "remapper"
            "remappers"
            "noremap"
            "submaps"
            "hjkl"
            "sexp"
            "spacebar"
            "bigrams"
            "autocmds"
            # Editors
            "Spacemacs"
            "Kakoune"
            "Magit"
            "folke"
            "Moonlander"
            "Colemak"
            "Pulumi"
            "Terrascan"
            "Qwen"
            "Neur"
            "Ilroy"
            "neuro"
            # Concepts
            "satisficing"
            "automaticity"
            "declarativeness"
            "underspecified"
            "unspecifiable"
            "metamodel"
          ];
          # Ignore proper nouns, acronyms, and bold-split fragments like **B**uffer
          ignoreRegExpList = [
            "/\\b[A-Z][a-zà-ÿ'']{2,}\\b/g"
            "/\\b[A-Z]{2,}\\b/g"
            "/\\*\\*\\w\\*\\*\\w+/g"
          ];
        };
      };

      # DevShell with pre-commit hooks
      devShells.default = pkgs.mkShell {
        shellHook = config.pre-commit.installationScript;
        packages = with pkgs; [
          statix
          deadnix
          nvd
          nix-output-monitor
          process-compose
        ];
      };

      # Minimal CI devShell (no interactive tools)
      devShells.ci = pkgs.mkShell {
        packages = with pkgs; [
          statix
          deadnix
        ];
      };
    };
}
