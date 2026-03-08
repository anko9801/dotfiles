# Git for Windows (WHM module)
# Subset of git.nix settings suitable for Windows
_:
let
  user = (import ../../config.nix).users.anko;
  globalIgnores = import ./ignores.nix;
in
{
  programs.git = {
    enable = true;
    ignores = globalIgnores;
    settings = {
      user = {
        inherit (user.git) name email;
      };

      alias = {
        st = "status -sb";
        lg = "log --graph --all --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)' --abbrev-commit";
        root = "rev-parse --show-toplevel";
        branches = "branch -a --sort=-authordate";
        stashes = "stash list";
        remotes = "remote -v";
        untracked = "ls-files --others --exclude-standard";
        ignored = "ls-files --ignored --exclude-standard --others";
        aliases = "config --get-regexp '^alias\\.'";
        sw = "switch";
        current = "rev-parse --abbrev-ref HEAD";
        branch-diff = "diff main...HEAD";
        ps = "push";
        pl = "pull";
        please = "push --force-with-lease --force-if-includes";
        unstage = "restore --staged";
        amend = "commit --amend";
        uncommit = "reset --mixed HEAD~";
        nevermind = "reset --hard HEAD";
        absorb = "absorb --and-rebase";
      };

      color.ui = "auto";
      column.ui = "auto";
      init.defaultBranch = "main";

      core = {
        autocrlf = false;
        safecrlf = true;
        quotepath = false;
        untrackedCache = true;
        fsmonitor = true;
        editor = "code --wait";
      };

      diff = {
        algorithm = "histogram";
        renames = true;
        colorMoved = "plain";
        mnemonicPrefix = true;
      };

      merge.conflictstyle = "zdiff3";

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
      };

      submodule.recurse = true;

      rebase = {
        autostash = true;
        autosquash = true;
        updateRefs = true;
      };

      rerere = {
        enabled = true;
        autoupdate = true;
      };

      branch = {
        autosetupmerge = "always";
        autosetuprebase = "always";
        sort = "-committerdate";
      };

      tag.sort = "version:refname";

      commit.verbose = true;
      help.autocorrect = "prompt";
      status.showUntrackedFiles = "all";
      log.date = "iso";
      feature.manyFiles = true;
      credential.helper = "manager";

      advice = {
        addIgnoredFile = false;
        statusHints = false;
        commitBeforeMerge = false;
        detachedHead = false;
      };
    };
  };
}
