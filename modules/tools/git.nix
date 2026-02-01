{ pkgs, userConfig, ... }:

{
  home = {
    packages = with pkgs; [ difftastic ];

    file = {
      ".config/git/allowed_signers".text = ''
        ${userConfig.git.email} ${userConfig.git.sshKey}
      '';

      ".gitmojirc.json".text = builtins.toJSON {
        autoAdd = false;
        emojiFormat = "emoji";
        scopePrompt = false;
        messagePrompt = true;
        capitalizeTitle = true;
      };

      ".config/git/hooks/pre-commit" = {
        executable = true;
        text = ''
          #!/usr/bin/env bash
          set -euo pipefail
          if ! command -v gitleaks &>/dev/null; then
              echo "Warning: gitleaks not found. Install it to scan for secrets."
              exit 0
          fi
          gitleaks protect --staged --redact --exit-code 1
        '';
      };
    };
  };

  programs.git = {
    enable = true;

    signing = {
      key = userConfig.git.sshKey;
      signByDefault = true;
    };

    settings = {
      user = {
        inherit (userConfig.git) name email;
      };

      gpg.ssh.allowedSignersFile = "~/.config/git/allowed_signers";

      # ==============================================================================
      # Core
      # ==============================================================================
      core = {
        editor = "nvim";
        autocrlf = false;
        safecrlf = true;
        filemode = false;
        pager = "delta";
        hooksPath = "~/.config/git/hooks";
        quotepath = false; # 日本語ファイル名を正しく表示
        untrackedCache = true; # git status 高速化
      };

      color.ui = "auto";
      column.ui = "auto";

      # ==============================================================================
      # Diff/Merge
      # ==============================================================================
      diff = {
        algorithm = "histogram"; # patience より高速で正確
        renames = true;
        colorMoved = "plain";
        mnemonicPrefix = true; # a/b → i/w/c (index/worktree/commit)
        external = "difft"; # 構文認識diff
      };

      merge = {
        tool = "vimdiff";
        conflictstyle = "zdiff3"; # 元コード+両者を表示、変更ない行は省略
      };

      interactive.diffFilter = "delta --color-only";

      # ==============================================================================
      # Pull/Push/Fetch
      # ==============================================================================
      # pull: ff=only で意図しないmergeを防ぎ、rebase=true で分岐時は自動rebase
      pull = {
        ff = "only";
        rebase = true;
      };

      push = {
        autoSetupRemote = true; # 初回pushで自動的にupstream設定
        default = "current";
        followTags = true; # push時にタグも送信
      };

      fetch = {
        prune = true; # 削除されたリモートブランチをローカルからも削除
        pruneTags = true;
        all = true;
        fsckobjects = true; # 破損オブジェクト検出
      };

      submodule.recurse = true;

      # ==============================================================================
      # Rebase/Merge workflow
      # ==============================================================================
      rebase = {
        autostash = true; # rebase前に自動stash
        autosquash = true; # fixup! コミットを自動squash
        updateRefs = true; # スタックしたブランチも更新
      };

      # rerere: コンフリクト解決を記録し、同じ解決を自動適用
      rerere = {
        enabled = true;
        autoupdate = true;
      };

      # ==============================================================================
      # Branch/Tag
      # ==============================================================================
      branch = {
        autosetupmerge = "always";
        autosetuprebase = "always";
        sort = "-committerdate"; # 最新ブランチを上に
      };

      tag = {
        gpgsign = true;
        sort = "version:refname"; # v1.9 < v1.10 の正しいソート
      };

      # ==============================================================================
      # Misc
      # ==============================================================================
      init.defaultBranch = "main";
      commit.verbose = true; # コミット時にdiffを表示
      help.autocorrect = "prompt";
      status.showUntrackedFiles = "all";
      log.date = "iso";
      feature.manyFiles = true; # 大規模リポジトリ最適化

      transfer.fsckobjects = true;
      receive.fsckObjects = true;

      url."ssh://git@github.com/".insteadOf = "https://github.com/";

      # ==============================================================================
      # Aliases
      # ==============================================================================
      # 方針: エディタ(VSCode/Neovim)とLLM(Claude)で代替できるものは省く
      alias = {
        # 状態確認
        st = "status -sb";
        l = "log --graph --pretty=format:'%C(yellow)%h %C(cyan)%ar %C(reset)%s%C(auto)%d' -20";
        lp = "log -p --ext-diff";
        cp = "cherry-pick";

        # Push/Pull
        ps = "push";
        pl = "pull";
        please = "push --force-with-lease --force-if-includes"; # 安全なforce push

        # コミット
        vibecommit = ''
          !claude -p "Generate a conventional commit message for this diff. Output plaintext only, no codeblock:
          $(git diff --cached)" | git commit --edit --trailer "Assisted-by: Claude" -F -'';
        undo = "reset HEAD~1 --mixed"; # 直前コミット取消 (変更は残す)
        fixup = "commit --fixup HEAD"; # autosquash用

        # 緊急操作
        nevermind = "!git reset --hard HEAD && git clean -d -f"; # 全変更破棄

        # ブランチ整理
        prune = "!git fetch --prune && git branch -vv | grep ': gone]' | awk '{print $1}' | xargs -r git branch -d";

        # スクリプト用
        root = "rev-parse --show-toplevel";
        current = "rev-parse --abbrev-ref HEAD";
      };
    };

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

    lfs.enable = true;
  };

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
