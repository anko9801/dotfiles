{ pkgs, userConfig, ... }:

let
  inherit (userConfig) editor;
  inherit (userConfig.git) name email sshKey;

  # Global gitignore patterns
  globalIgnores = [
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
    ".worktrees/"
  ];

  # Git aliases
  aliases = {
    # Status/Log
    st = "status -sb";
    lg = "log --graph --all --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)' --abbrev-commit";
    root = "rev-parse --show-toplevel";

    # Branch
    sw = "switch";
    safe-switch = "!git stash push -m \"switch: $(git branch --show-current) -> $1\" && git stash apply && git switch \"$@\"";
    current = "rev-parse --abbrev-ref HEAD";
    remember = "!git diff $(git merge-base HEAD $(git symbolic-ref refs/remotes/origin/HEAD | sed 's@refs/remotes/origin/@@'))";

    # Push/Pull
    ps = "push";
    pl = "!git pull && git branch -vv | grep ': gone]' | awk '{print $1}' | xargs -r git branch -d";
    please = "push --force-with-lease --force-if-includes";

    # Commit
    unstage = "restore --staged";
    amend = "commit --amend";
    undo = "reset HEAD~1 --mixed";
    nevermind = "!git reset --hard HEAD && git clean -d -f";

    fixup = "commit --fixup HEAD";
    # absorb: auto-fixup + rebase, falls back to interactive on failure
    absorb = "absorb --and-rebase";
  };

  # Pre-commit hook for secret detection
  preCommitHook = ''
    #!/usr/bin/env bash
    set -euo pipefail
    if ! command -v gitleaks &>/dev/null; then
        echo "Warning: gitleaks not found. Install it to scan for secrets."
        exit 0
    fi
    gitleaks protect --staged --redact --exit-code 1
  '';
in
{
  home = {
    packages = with pkgs; [
      difftastic
      git-wt
      git-absorb
      onefetch
    ];

    # difftastic: auto-fallback to text diff for large changes
    sessionVariables.DFT_GRAPH_LIMIT = "10000";

    file = {
      ".config/git/allowed_signers".text = "${email} ${sshKey}";

      # czg config (conventional commits with emoji)
      ".czrc".text = builtins.toJSON {
        useEmoji = true;
        emojiAlign = "center";
        types = [
          {
            value = "feat";
            name = "feat:     ✨ A new feature";
            emoji = "✨";
          }
          {
            value = "fix";
            name = "fix:      🐛 A bug fix";
            emoji = "🐛";
          }
          {
            value = "docs";
            name = "docs:     📝 Documentation only changes";
            emoji = "📝";
          }
          {
            value = "style";
            name = "style:    💄 Code style (formatting, semicolons, etc)";
            emoji = "💄";
          }
          {
            value = "refactor";
            name = "refactor: ♻️  Code refactoring";
            emoji = "♻️";
          }
          {
            value = "perf";
            name = "perf:     ⚡️ Performance improvements";
            emoji = "⚡️";
          }
          {
            value = "test";
            name = "test:     ✅ Adding or updating tests";
            emoji = "✅";
          }
          {
            value = "build";
            name = "build:    📦 Build system or dependencies";
            emoji = "📦";
          }
          {
            value = "ci";
            name = "ci:       🎡 CI/CD configuration";
            emoji = "🎡";
          }
          {
            value = "chore";
            name = "chore:    🔧 Other changes (tooling, etc)";
            emoji = "🔧";
          }
          {
            value = "revert";
            name = "revert:   ⏪ Revert a commit";
            emoji = "⏪";
          }
        ];
        allowCustomScopes = true;
        allowEmptyScopes = true;
        allowBreakingChanges = [
          "feat"
          "fix"
        ];
        upperCaseSubject = false;
        skipQuestions = [
          "body"
          "footerPrefix"
          "footer"
        ];
      };

      ".config/git/hooks/pre-commit" = {
        executable = true;
        text = preCommitHook;
      };
    };
  };

  programs.git = {
    enable = true;
    lfs.enable = true;
    ignores = globalIgnores;

    signing = {
      key = sshKey;
      signByDefault = true;
    };

    settings = {
      user = { inherit name email; };
      gpg.ssh.allowedSignersFile = "~/.config/git/allowed_signers";
      alias = aliases;

      # === Core ===
      # fsmonitor + untrackedCache で大規模リポジトリを高速化
      core = {
        inherit editor;
        autocrlf = false;
        safecrlf = true;
        filemode = false;
        pager = "delta";
        hooksPath = "~/.config/git/hooks";
        quotepath = false;
        untrackedCache = true;
        fsmonitor = true;
      };

      color.ui = "auto";
      column.ui = "auto";
      init.defaultBranch = "main";

      # === Diff/Merge ===
      # histogram: patience より高速で、コードブロック移動の検出に強い
      # difft: 構文解析で意味のある差分を表示 (ノイズ削減)
      # zdiff3: ||| base ||| を表示し、どちらが何を変えたか明確に
      diff = {
        algorithm = "histogram";
        renames = true;
        colorMoved = "plain";
        mnemonicPrefix = true;
        external = "difft";
      };

      merge = {
        tool = "vimdiff";
        conflictstyle = "zdiff3";
      };

      interactive.diffFilter = "delta --color-only";

      # === Pull/Push ===
      pull = {
        ff = "only";
        rebase = true;
      };

      push = {
        autoSetupRemote = true;
        default = "current";
        followTags = true;
      };

      # === Fetch ===
      # fsckobjects: 破損オブジェクトの転送を防止
      fetch = {
        prune = true;
        pruneTags = true;
        all = true;
        fsckobjects = true;
      };

      submodule.recurse = true;

      # === Rebase ===
      # autosquash: fixup!/squash! コミットを自動で並べ替え
      # updateRefs: A→B→C のスタックを rebase 時に全て更新
      rebase = {
        autostash = true;
        autosquash = true;
        updateRefs = true;
      };

      # rerere: 同じコンフリクトを二度解決しない
      rerere = {
        enabled = true;
        autoupdate = true;
      };

      # === Branch/Tag ===
      branch = {
        autosetupmerge = "always";
        autosetuprebase = "always";
        sort = "-committerdate";
      };

      tag = {
        gpgsign = true;
        sort = "version:refname";
      };

      # === Misc ===
      wt.basedir = ".worktrees";
      blame.ignoreRevsFile = ".git-blame-ignore-revs";
      commit.verbose = true;
      help.autocorrect = "prompt";
      status.showUntrackedFiles = "all";
      log.date = "iso";
      feature.manyFiles = true;
      maintenance.auto = true;

      transfer.fsckobjects = true;
      receive.fsckObjects = true;

      url."ssh://git@github.com/".insteadOf = "https://github.com/";

      advice = {
        addIgnoredFile = false;
        statusHints = false;
        commitBeforeMerge = false;
        detachedHead = false;
      };
    };
  };

  programs.delta = {
    enable = true;
    options = {
      navigate = true;
      line-numbers = true;
      side-by-side = true;
      syntax-theme = "TwoDark";
      features = "decorations";
      hyperlinks = true;
      hyperlinks-file-link-format = "vscode://file/{path}:{line}";
      blame-palette = "#1e1e2e #313244 #45475a";
      decorations = {
        commit-decoration-style = "bold yellow box ul";
        file-style = "bold yellow ul";
        file-decoration-style = "none";
        hunk-header-decoration-style = "cyan box ul";
      };
    };
  };
}
