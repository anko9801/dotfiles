{
  pkgs,
  lib,
  config,
  userConfig,
  ...
}:

let
  inherit (config.platform) isDarwin isWSL;
  inherit (userConfig) editor;
  inherit (userConfig.git) name email sshKey;

  aliases = import ./aliases.nix;
  globalIgnores = import ./ignores.nix;
  czgConfig = import ./czg.nix;

  # Pre-commit hook for secret detection
  preCommitHook = ''
    #!/usr/bin/env bash
    set -euo pipefail
    if ! command -v gitleaks &>/dev/null; then
        echo "Error: gitleaks not found. Skipping with: SKIP=gitleaks git commit"
        exit 1
    fi
    [ "$SKIP" = "gitleaks" ] && exit 0
    gitleaks protect --staged --redact --exit-code 1
  '';
in
{
  imports = [ ./delta.nix ];

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
      ".czrc".text = builtins.toJSON czgConfig;
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
      gpg.ssh.allowedSignersFile = "${config.home.homeDirectory}/.config/git/allowed_signers";
      alias = aliases;

      # === Core ===
      core = {
        inherit editor;
        autocrlf = false;
        safecrlf = true;
        filemode = false;
        pager = "delta";
        hooksPath = "${config.home.homeDirectory}/.config/git/hooks";
        quotepath = false;
        untrackedCache = true;
        fsmonitor = true;
      };

      color.ui = "auto";
      column.ui = "auto";
      init.defaultBranch = "main";

      # === Diff/Merge ===
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
      fetch = {
        prune = true;
        pruneTags = true;
        all = true;
        fsckobjects = true;
      };

      submodule.recurse = true;

      # === Rebase ===
      rebase = {
        autostash = true;
        autosquash = true;
        updateRefs = true;
      };

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
    }
    // lib.optionalAttrs isDarwin { credential.helper = "osxkeychain"; }
    // lib.optionalAttrs isWSL { credential.helper = "!git-credential-manager.exe"; };
  };
}
