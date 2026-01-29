{ pkgs, ... }:

{
  home = {
    # difftastic for structural diffs
    packages = with pkgs; [ difftastic ];

    file = {
      # Git allowed signers file
      ".config/git/allowed_signers".text = ''
        37263451+anko9801@users.noreply.github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEpnmapaBsLWiMwmg201YFSh8J776ICJ8GnOEs5YmT/M
      '';

      # Gitmoji configuration
      ".gitmojirc.json".text = builtins.toJSON {
        autoAdd = false;
        emojiFormat = "emoji";
        scopePrompt = false;
        messagePrompt = true;
        capitalizeTitle = true;
      };

      # Git pre-commit hook for gitleaks
      ".config/git/hooks/pre-commit" = {
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
    };
  };

  programs.git = {
    enable = true;

    # SSH signing (disabled - requires 1Password SSH agent setup)
    # To enable: set up SSH key in WSL or Windows 1Password bridge
    signing = {
      key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEpnmapaBsLWiMwmg201YFSh8J776ICJ8GnOEs5YmT/M";
      signByDefault = false;
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

      # Column output
      column.ui = "auto";

      # Merge/Diff
      merge = {
        tool = "vimdiff";
        conflictstyle = "diff3";
      };
      diff = {
        algorithm = "histogram";
        renames = true;
        colorMoved = "plain";
        mnemonicPrefix = true;
        external = "difft";
      };
      interactive.diffFilter = "delta --color-only";

      # Pull/Push/Fetch
      pull.ff = "only";
      push = {
        autoSetupRemote = true;
        default = "current";
        followTags = true;
      };
      fetch = {
        prune = true;
        pruneTags = true;
        all = true;
        fsckobjects = true;
      };

      # Rebase
      rebase = {
        autostash = true;
        autosquash = true;
        updateRefs = true;
      };

      # Init
      init.defaultBranch = "main";

      # Commit
      commit.verbose = true;

      # Help
      help.autocorrect = "prompt";

      # Rerere - remember conflict resolutions
      rerere = {
        enabled = true;
        autoupdate = true;
      };

      # Branch
      branch = {
        autosetupmerge = "always";
        autosetuprebase = "always";
        sort = "-committerdate";
      };

      # Tag
      tag = {
        gpgsign = false; # Disabled until SSH signing is set up
        sort = "version:refname";
      };

      # Status
      status.showUntrackedFiles = "all";

      # Transfer
      transfer.fsckobjects = true;
      receive.fsckObjects = true;

      # Use SSH instead of HTTPS for GitHub
      url."ssh://git@github.com/".insteadOf = "https://github.com/";

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
        lg = "log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset)%C(bold yellow)%d%C(reset)%n''          %C(white)%s%C(reset) %C(dim white)- %an%C(reset)' --all";
        la = "log --oneline --graph --decorate --all";
        ll = "log --oneline --graph --decorate";
        last = "log -1 HEAD";
        contributors = "shortlog -sn";

        # Diff operations
        df = "diff --color-words";
        staged = "diff --staged";
        dfs = "diff --staged";
        unstage = "reset HEAD --";

        # Branch management
        cleanup = "!git branch --merged | grep -v '\\*\\|main\\|master\\|develop' | xargs -n 1 git branch -d";
        br-prune = "!git fetch --prune && git branch -vv | grep ': gone]' | awk '{print $1}' | xargs -r git branch -d";

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

}
