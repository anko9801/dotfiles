# Git aliases
# ─────────────────────────────────────────────────────────────────
# Status/Log:
#   st        - Short status with branch info
#   lg        - Pretty graph log with colors
#   root      - Print repository root path
# List:
#   branches  - List all branches (sorted by date)
#   stashes   - List all stashes
#   remotes   - List all remotes
#   untracked - List untracked files
#   ignored   - List ignored files
#   aliases   - List all git aliases
# Branch:
#   sw        - Switch branch (shorthand)
#   current   - Print current branch name
#   branch-diff - Show all changes since branching from main
# Push/Pull:
#   ps        - Push (shorthand)
#   pl        - Pull + delete local branches that were deleted on remote
#   please    - Force push safely (lease + if-includes)
# Commit:
#   unstage   - Unstage files (restore --staged), use `restore` to discard changes
#   amend     - Amend last commit
#   uncommit  - Undo last commit, keep changes unstaged
#   nevermind - Discard ALL changes (hard reset + clean untracked)
#   absorb    - Auto-fixup staged changes into appropriate commits
# ─────────────────────────────────────────────────────────────────
{
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
  aliases = "!git config --get-regexp '^alias\\.' | sed 's/alias\\.\\([^ ]*\\) \\(.*\\)/\\1\t=> \\2/'";

  # Branch
  sw = "switch";
  current = "rev-parse --abbrev-ref HEAD";
  branch-diff = "!git diff $(git merge-base HEAD $(git symbolic-ref refs/remotes/origin/HEAD | sed 's@refs/remotes/origin/@@'))";

  # Push/Pull
  ps = "push";
  pl = "!git pull && git branch -vv | grep ': gone]' | awk '{print $1}' | xargs -r git branch -d";
  please = "push --force-with-lease --force-if-includes";

  # Commit
  unstage = "restore --staged";
  amend = "commit --amend";
  uncommit = "reset --mixed HEAD~";
  nevermind = "!git reset --hard HEAD && git clean -d -f";
  absorb = "absorb --and-rebase";
}
