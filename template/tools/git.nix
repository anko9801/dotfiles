# baseModule: git configuration
# Demonstrates how config.defaults.identity wires user info into tools
{ config, ... }:
let
  inherit (config.defaults.identity) name email;
in
{
  programs.git = {
    enable = true;
    lfs.enable = true;

    # Identity from config.nix -> defaults.identity -> here
    settings = {
      user = {
        inherit name email;
      };

      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
      fetch.prune = true;
      rebase.autostash = true;
      diff.algorithm = "histogram";
      merge.conflictstyle = "zdiff3";
      rerere.enabled = true;

      alias = {
        st = "status -sb";
        lg = "log --graph --oneline --all --decorate";
        sw = "switch";
        unstage = "restore --staged";
        amend = "commit --amend";
      };
    };
  };
}
