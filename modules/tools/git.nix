{ pkgs, userConfig, ... }:

{
  home = {
    # difftastic for structural diffs
    packages = with pkgs; [ difftastic ];

    file = {
      # Git allowed signers file
      ".config/git/allowed_signers".text = ''
        ${userConfig.git.email} ${userConfig.git.sshKey}
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

    # SSH signing with 1Password
    signing = {
      key = userConfig.git.sshKey;
      signByDefault = true;
    };

    # All settings using the new format
    settings = {
      # User settings
      user = {
        inherit (userConfig.git) name email;
      };

      # SSH signing - allowed signers file (gpg.format is set in ssh.nix)
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
        untrackedCache = true; # パフォーマンス向上
      };

      # Colors
      color.ui = "auto";

      # Column output
      column.ui = "auto";

      # Merge/Diff
      merge = {
        tool = "vimdiff";
        conflictstyle = "zdiff3"; # diff3より読みやすい (変更ない行を省略)
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
      # pull設定:
      # - ff=only: mergeコミット作成を防ぐ
      # - rebase=true: 分岐時は自動rebase (mergeではなく)
      pull = {
        ff = "only";
        rebase = true;
      };
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

      # Submodule
      submodule.recurse = true;

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
        gpgsign = true;
        sort = "version:refname";
      };

      # Status
      status.showUntrackedFiles = "all";

      # Log
      log.date = "iso";

      # Performance (大規模リポジトリ向け)
      feature.manyFiles = true;

      # Transfer
      transfer.fsckobjects = true;
      receive.fsckObjects = true;

      # Use SSH instead of HTTPS for GitHub
      url."ssh://git@github.com/".insteadOf = "https://github.com/";

      # Aliases
      # 方針: エディタ(VSCode/Neovim)とLLM(Claude)で代替できるものは省く
      # - diff/stage/stash/log視覚化 → エディタのGit UIが優秀
      # - コミットメッセージ生成 → Claude が生成
      # - 残すのは: ターミナルで素早く打ちたいもの、緊急操作、自動化用
      alias = {
        # 状態確認 (ターミナルにいる時用)
        st = "status -sb";
        l = "log --graph --pretty=format:'%C(yellow)%h %C(cyan)%ar %C(reset)%s%C(auto)%d' -20";
        lp = "log -p --ext-diff"; # パッチ付き (difftastic)
        cp = "cherry-pick";

        # Push/Pull (pull.rebase=true で分岐時も自動rebase)
        ps = "push";
        pl = "pull";
        please = "push --force-with-lease --force-if-includes";

        # コミット (Claude でメッセージ生成、編集可能)
        vibecommit = ''
          !claude -p "Generate a conventional commit message for this diff. Output plaintext only, no codeblock:
          $(git diff --cached)" | git commit --edit --trailer "Assisted-by: Claude" -F -'';
        undo = "reset HEAD~1 --mixed";
        fixup = "commit --fixup HEAD"; # rebase -i --autosquash で自動squash

        # 緊急操作 (素早く打てることが重要)
        nevermind = "!git reset --hard HEAD && git clean -d -f";

        # ブランチ整理 (自動化)
        prune = "!git fetch --prune && git branch -vv | grep ': gone]' | awk '{print $1}' | xargs -r git branch -d";

        # スクリプト用
        root = "rev-parse --show-toplevel";
        current = "rev-parse --abbrev-ref HEAD";
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
