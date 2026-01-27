{ pkgs, ... }:

{
  # difftastic for structural diffs
  home.packages = with pkgs; [ difftastic ];

  programs.git = {
    enable = true;

    # SSH signing with 1Password
    signing = {
      key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEpnmapaBsLWiMwmg201YFSh8J776ICJ8GnOEs5YmT/M";
      signByDefault = true;
    };

    # All settings using the new format
    settings = {
      # User settings
      user = {
        name = "anko9801";
        email = "37263451+anko9801@users.noreply.github.com";
      };

      # GPG/SSH signing format
      gpg.format = "ssh";
      gpg.ssh.allowedSignersFile = "~/.config/git/allowed_signers";

      # Core settings
      core = {
        editor = "nvim";
        autocrlf = false;
        safecrlf = true;
        filemode = false;
        pager = "delta";
        hooksPath = "~/.config/git/hooks";
        quotepath = false;
      };

      # Colors
      color.ui = "auto";

      # Merge/Diff
      merge = {
        tool = "vimdiff";
        conflictstyle = "diff3";
      };
      diff = {
        renames = true;
        colorMoved = "default";
        external = "difft";
      };
      interactive.diffFilter = "delta --color-only";

      # Pull/Push/Fetch
      pull.ff = "only";
      push = {
        autoSetupRemote = true;
        default = "current";
      };
      fetch = {
        prune = true;
        fsckobjects = true;
      };

      # Rebase
      rebase = {
        autostash = true;
        autosquash = true;
      };

      # Init
      init.defaultBranch = "main";

      # Commit/Tag
      commit.verbose = true;
      tag.gpgsign = true;

      # Help
      help.autocorrect = "prompt";

      # Rerere - remember conflict resolutions
      rerere.enabled = true;

      # Branch
      branch = {
        autosetupmerge = "always";
        autosetuprebase = "always";
      };

      # Status
      status.showUntrackedFiles = "all";

      # Transfer
      transfer.fsckobjects = true;
      receive.fsckObjects = true;

      # Aliases
      alias = {
        # Status and basic operations
        st = "status -sb";
        co = "checkout";
        br = "branch";
        sw = "switch";
        re = "restore";

        # Commit operations
        c = "commit";
        cm = "commit -m";
        a = "add --all";
        amend = "commit --amend --no-edit";
        commend = "commit --amend --no-edit";
        undo = "reset HEAD~1 --mixed";

        # Push/Pull operations
        ps = "push";
        pl = "pull";
        f = "fetch --prune";
        please = "push --force-with-lease";

        # Log and history
        lg = "log --oneline --graph --decorate";
        la = "log --oneline --graph --decorate --all";
        last = "log -1 HEAD";
        contributors = "shortlog -sn";

        # Diff operations
        df = "diff --color-words";
        staged = "diff --staged";
        dfs = "diff --staged";
        unstage = "reset HEAD --";

        # Branch management
        cleanup = "!git branch --merged | grep -v '\\*\\|main\\|master\\|develop' | xargs -n 1 git branch -d";

        # Utilities
        it = "!git init && git commit -m 'Initial commit' --allow-empty";
        wip = "!git add -A && git commit -m 'WIP'";
        open = "!gh browse";
      };
    };

    # Global gitignore
    ignores = [
      # OS
      ".DS_Store"
      "Thumbs.db"
      "Desktop.ini"

      # Editors
      "*.swp"
      "*.swo"
      "*~"
      ".idea/"
      ".vscode/"
      "*.sublime-*"
      ".*.un~"

      # Build artifacts
      "node_modules/"
      "__pycache__/"
      "*.pyc"
      "*.pyo"
      ".pytest_cache/"
      "target/"
      "dist/"
      "build/"
      "*.egg-info/"

      # Environment
      ".env"
      ".env.local"
      ".env.*.local"
      ".envrc"
      ".direnv/"

      # Logs
      "*.log"
      "npm-debug.log*"
      "yarn-debug.log*"
      "yarn-error.log*"

      # Misc
      "*.bak"
      "*.tmp"
      "*.temp"
      ".cache/"
    ];

    # LFS support
    lfs.enable = true;
  };

  # Delta for better diffs
  programs.delta = {
    enable = true;
    options = {
      navigate = true;
      line-numbers = true;
      side-by-side = true;
      syntax-theme = "TwoDark";
      features = "decorations";
      decorations = {
        commit-decoration-style = "bold yellow box ul";
        file-style = "bold yellow ul";
        file-decoration-style = "none";
        hunk-header-decoration-style = "cyan box ul";
      };
    };
  };

  # Git allowed signers file
  home.file.".config/git/allowed_signers".text = ''
    37263451+anko9801@users.noreply.github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEpnmapaBsLWiMwmg201YFSh8J776ICJ8GnOEs5YmT/M
  '';

  # Git pre-commit hook for gitleaks
  home.file.".config/git/hooks/pre-commit" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # Git pre-commit hook - prevent committing secrets

      set -euo pipefail

      # Check if gitleaks is installed
      if ! command -v gitleaks &>/dev/null; then
          echo "Warning: gitleaks not found. Install it to scan for secrets."
          exit 0
      fi

      # Run gitleaks on staged changes
      gitleaks protect --staged --redact --exit-code 1
    '';
  };
}
