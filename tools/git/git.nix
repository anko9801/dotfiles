{
  pkgs,
  lib,
  config,
  ...
}:

let
  p = config.platform;
  inherit (config.defaults) editor;
  inherit (config.defaults.identity) name email sshKey;

  # Platform helpers
  isUnix = p.os != "windows";
  unixOnly = lib.optionalAttrs isUnix;
  unixIf = lib.mkIf isUnix;

  # Platform-specific alias helper
  mkAlias =
    {
      default,
      windows ? default,
    }:
    if p.os == "windows" then windows else default;

  czgConfig = import ./czg.nix;
  globalIgnores = import ./ignores.nix;

  preCommitHook = ''
    #!/usr/bin/env bash
    set -euo pipefail
    if ! command -v gitleaks &>/dev/null; then
        echo "Error: gitleaks not found. Skipping with: SKIP=gitleaks git commit"
        exit 1
    fi
    [ "''${SKIP:-}" = "gitleaks" ] && exit 0
    gitleaks protect --staged --redact --exit-code 1
  '';
in
{
  imports = [ ./delta.nix ];

  home = unixIf {
    packages = with pkgs; [
      difftastic
      git-wt
      git-absorb
      onefetch
    ];

    sessionVariables.DFT_GRAPH_LIMIT = "10000";

    file = {
      ".config/git/allowed_signers".text = "${email} ${sshKey}";
      ".czrc".text = builtins.toJSON czgConfig;
      ".config/git/hooks/pre-commit" = {
        executable = true;
        text = preCommitHook;
      };
    };
  };

  programs.git = {
    enable = true;
    lfs.enable = isUnix;
    ignores = globalIgnores;

    signing = unixIf {
      key = sshKey;
      signByDefault = true;
    };

    settings = {
      user = { inherit name email; };

      alias = {
        # Status/Log
        st = "status -sb";
        lg = "log --graph --all --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)' --abbrev-commit";
        root = "rev-parse --show-toplevel";

        # List
        branches = "branch -a --sort=-authordate";
        stashes = "stash list";
        remotes = "remote -v";
        untracked = "ls-files --others --exclude-standard";
        ignored = "ls-files --ignored --exclude-standard --others";
        aliases = mkAlias {
          default = "!git config --get-regexp '^alias\\.' | sed 's/alias\\.\\([^ ]*\\) \\(.*\\)/\\1\t=> \\2/'";
          windows = "config --get-regexp '^alias\\.'";
        };

        # Branch
        sw = "switch";
        current = "rev-parse --abbrev-ref HEAD";
        branch-diff = mkAlias {
          default = "!git diff $(git merge-base HEAD $(git symbolic-ref refs/remotes/origin/HEAD | sed 's@refs/remotes/origin/@@'))";
          windows = "diff main...HEAD";
        };

        # Push/Pull
        ps = "push";
        pl = mkAlias {
          default = "!git pull && git branch -vv | grep ': gone]' | awk '{print $1}' | xargs -r git branch -d";
          windows = "pull";
        };
        please = "push --force-with-lease --force-if-includes";

        # Commit
        unstage = "restore --staged";
        amend = "commit --amend";
        uncommit = "reset --mixed HEAD~";
        nevermind = mkAlias {
          default = "!git reset --hard HEAD && git clean -d -f";
          windows = "reset --hard HEAD";
        };
        absorb = "absorb --and-rebase";
      };

      color.ui = "auto";
      column.ui = "auto";
      init.defaultBranch = "main";

      # Core
      core = {
        autocrlf = false;
        safecrlf = true;
        quotepath = false;
        untrackedCache = true;
        fsmonitor = true;
      }
      // unixOnly {
        inherit editor;
        filemode = false;
        pager = "delta";
        hooksPath = "${config.home.homeDirectory}/.config/git/hooks";
      }
      // lib.optionalAttrs (p.os == "windows") {
        editor = "code --wait";
      };

      # Diff/Merge
      diff = {
        algorithm = "histogram";
        renames = true;
        colorMoved = "plain";
        mnemonicPrefix = true;
      }
      // unixOnly {
        external = "difft";
      };

      merge = {
        conflictstyle = "zdiff3";
      }
      // unixOnly {
        tool = "vimdiff";
      };

      interactive = unixIf {
        diffFilter = "delta --color-only";
      };

      # Pull/Push
      pull = {
        ff = "only";
        rebase = true;
      };

      push = {
        autoSetupRemote = true;
        default = "current";
        followTags = true;
      };

      # Fetch
      fetch = {
        prune = true;
        pruneTags = true;
        all = true;
      }
      // unixOnly {
        fsckobjects = true;
      };

      submodule.recurse = true;

      # Rebase
      rebase = {
        autostash = true;
        autosquash = true;
        updateRefs = true;
      };

      rerere = {
        enabled = true;
        autoupdate = true;
      };

      # Branch/Tag
      branch = {
        autosetupmerge = "always";
        autosetuprebase = "always";
        sort = "-committerdate";
      };

      tag = {
        sort = "version:refname";
      }
      // unixOnly {
        gpgsign = true;
      };

      # Misc
      commit.verbose = true;
      help.autocorrect = "prompt";
      status.showUntrackedFiles = "all";
      log.date = "iso";
      feature.manyFiles = true;

      # Security (Linux only)
      transfer = unixIf { fsckobjects = true; };
      receive = unixIf { fsckObjects = true; };

      # Paths (Linux only)
      gpg.ssh.allowedSignersFile = unixIf "${config.home.homeDirectory}/.config/git/allowed_signers";
      wt.basedir = unixIf ".worktrees";
      blame.ignoreRevsFile = unixIf ".git-blame-ignore-revs";
      maintenance.auto = unixIf true;
      url."ssh://git@github.com/".insteadOf = unixIf "https://github.com/";

      # Advice (reduce noise)
      advice = {
        addIgnoredFile = false;
        statusHints = false;
        commitBeforeMerge = false;
        detachedHead = false;
      };

      # Credential helper
      credential = lib.mkMerge [
        (lib.mkIf (p.os == "darwin") { helper = "osxkeychain"; })
        (lib.mkIf (p.environment == "wsl") { helper = "!git-credential-manager.exe"; })
        (lib.mkIf (p.os == "windows") { helper = "manager"; })
      ];
    };
  };
}
