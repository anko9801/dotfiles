# Merge Main

Merge the main/master branch into the current branch safely.

## Current State

**Current Branch:** `!git branch --show-current`
**Default Branch:** `!git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo "main"`
**Behind/Ahead:**
```
!git fetch origin --quiet && git rev-list --left-right --count origin/$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo "main")...HEAD 2>/dev/null || echo "Unable to compare"
```

## Workflow

1. Fetch latest from origin: `git fetch origin`
2. Check if merge is needed (behind count > 0)
3. Attempt merge: `git merge origin/main` (or origin/master)
4. If conflicts occur:
   - List conflicted files: `git diff --name-only --diff-filter=U`
   - For each conflict:
     - Read the file and understand both versions
     - Resolve intelligently (prefer incoming changes unless local changes are intentional)
     - Mark as resolved: `git add <file>`
   - Complete merge: `git commit --no-edit`
5. Run verification:
   - `nix flake check` for Nix projects
   - Run tests if applicable
6. Push if all checks pass: `git push`

## Conflict Resolution Strategy

- **Config files**: Merge carefully, preserve local customizations
- **Lock files**: Accept incoming and regenerate if needed
- **Code changes**: Understand intent of both changes, combine logically
- **Documentation**: Usually accept incoming unless local has important updates

$ARGUMENTS
