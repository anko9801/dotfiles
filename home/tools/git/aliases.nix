# Git aliases
# ─────────────────────────────────────────────────────────────────
# Status/Log:
#   st      - Short status with branch info
#   lg      - Pretty graph log with colors
#   root    - Print repository root path
# Branch:
#   sw      - Switch branch (shorthand)
#   safe-switch - Stash, switch, then apply stash (safe branch change)
#   current - Print current branch name
#   remember - Show diff from branch point (what changed since fork)
# Push/Pull:
#   ps      - Push (shorthand)
#   pl      - Pull + delete local branches that were deleted on remote
#   please  - Force push safely (lease + if-includes)
# Commit:
#   unstage - Unstage files from index
#   amend   - Amend last commit
#   undo    - Undo last commit, keep changes staged
#   nevermind - Discard all changes (hard reset + clean)
#   fixup   - Create fixup commit for HEAD
#   absorb  - Auto-fixup staged changes into appropriate commits
# ─────────────────────────────────────────────────────────────────
{
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
  absorb = "absorb --and-rebase";
}
