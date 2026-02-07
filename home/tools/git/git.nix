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

  czgConfig = import ./czg.nix;

  # Shared config path (SSoT for common settings)
  sharedConfigPath = "${config.home.homeDirectory}/dotfiles/shared/git/config";
  sharedIgnorePath = "${config.home.homeDirectory}/dotfiles/shared/git/ignore";

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

  home = {
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
    lfs.enable = true;

    signing = {
      key = sshKey;
      signByDefault = true;
    };

    # Platform-specific settings only (common settings via include)
    settings = {
      include.path = sharedConfigPath;

      user = { inherit name email; };
      gpg.ssh.allowedSignersFile = "${config.home.homeDirectory}/.config/git/allowed_signers";

      core = {
        inherit editor;
        filemode = false;
        pager = "delta";
        hooksPath = "${config.home.homeDirectory}/.config/git/hooks";
        excludesFile = sharedIgnorePath;
      };

      diff.external = "difft";
      merge.tool = "vimdiff";
      interactive.diffFilter = "delta --color-only";

      fetch.fsckobjects = true;
      transfer.fsckobjects = true;
      receive.fsckObjects = true;

      tag.gpgsign = true;
      wt.basedir = ".worktrees";
      blame.ignoreRevsFile = ".git-blame-ignore-revs";
      maintenance.auto = true;

      url."ssh://git@github.com/".insteadOf = "https://github.com/";
    }
    // lib.optionalAttrs isDarwin { credential.helper = "osxkeychain"; }
    // lib.optionalAttrs isWSL { credential.helper = "!git-credential-manager.exe"; };
  };
}
