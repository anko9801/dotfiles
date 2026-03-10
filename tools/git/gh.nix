{ pkgs, ... }:

{
  programs.gh = {
    enable = true;
    extensions = [ pkgs.gh-dash ];
    settings = {
      git_protocol = "ssh";
      prompt = "enabled";
      aliases = {
        co = "pr checkout";
        pv = "pr view";
        pc = "pr create";
        pm = "pr merge";
        il = "issue list";
        ic = "issue create";
        iv = "issue view";
        defaultbranch = ''
          !git rev-parse --git-dir > /dev/null 2>&1 || { echo "Not a git repository"; exit 1; }
          defaultbranch=''$(gh repo view --json defaultBranchRef --jq ".defaultBranchRef.name")
          [ -z "''$defaultbranch" ] && exit 0
          git config --local init.defaultBranch "''$defaultbranch"
          echo "''$defaultbranch"
        '';
        "pr wt" = ''
          !git rev-parse --git-dir >/dev/null 2>&1 || { echo "Not a git repository"; exit 1; }
          IFS=''$'\t' read -r num branch _ <<<"''$(gh pr list --json number,headRefName,title --jq '.[] | [.number, .headRefName, .title] | @tsv' | fzf)"
          [ -z "''$num" ] && exit 0
          base=''$(git rev-parse --show-toplevel)
          workdir="''${base%/*}/''$(basename "''$base").work/''${branch//\//-}"
          git worktree add -B "''$branch" "''$workdir" "origin/''$branch" && git -C "''$workdir" submodule update --init --recursive
        '';
        cleanup = ''!gh pr list --state merged --json headRefName -q ".[].headRefName" --limit 1000 | xargs -r git branch -D'';
      };
    };
  };
}
