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
          typos.enable = true;
        };
      };

      # Treefmt with extended formatters
      treefmt = {
        projectRootFile = "flake.nix";
        programs = {
          nixfmt.enable = true;
          shfmt.enable = true;
          yamlfmt.enable = true;
          keep-sorted.enable = true;
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
            # keep-sorted start
            "Colemak"
            "Ilroy"
            "Kakoune"
            "Karabiner"
            "Magit"
            "Moonlander"
            "Neur"
            "Pulumi"
            "Qwen"
            "Spacemacs"
            "Terrascan"
            "aerospace"
            "atuin"
            "autocmds"
            "automaticity"
            "bigrams"
            "bspwm"
            "cachix"
            "catppuccin"
            "chezmoi"
            "declarativeness"
            "devenv"
            "difftastic"
            "direnv"
            "dotfiles"
            "folke"
            "ghostty"
            "gitu"
            "gitui"
            "hjkl"
            "homebrew"
            "kanata"
            "keybinds"
            "keymap"
            "keymapping"
            "keymaps"
            "keypresses"
            "komorebi"
            "lazyworktree"
            "metamodel"
            "neovim"
            "neuro"
            "nix-darwin"
            "nixfmt"
            "nixpkgs"
            "nixvim"
            "noremap"
            "nvim"
            "remapper"
            "remappers"
            "satisficing"
            "sexp"
            "sketchybar"
            "spacebar"
            "starship"
            "stylix"
            "submaps"
            "sxhkd"
            "treefmt"
            "underspecified"
            "unspecifiable"
            "worktree"
            "xcape"
            "xremap"
            "yadm"
            "yazi"
            "zdiff"
            "zellij"
            "zinit"
            "zoxide"
            # keep-sorted end
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
          # keep-sorted start
          actionlint
          deadnix
          nix-output-monitor
          nvd
          process-compose
          statix
          zizmor
          # keep-sorted end
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
