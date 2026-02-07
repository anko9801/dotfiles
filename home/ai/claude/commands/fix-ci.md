# Fix CI

Diagnose and fix CI failures automatically.

## Current State

**Branch:** `!git branch --show-current`
**PR Check Status:**
```
!gh pr checks 2>/dev/null || echo "No PR found for current branch"
```

## Workflow

1. Analyze the check status above
2. If all checks pass, report success and exit
3. For failed checks:
   - Identify the failed run ID from `gh pr checks`
   - Get detailed logs: `gh run view <run-id> --log-failed`
   - Analyze the error output
4. Diagnose the root cause:
   - Build errors: Check syntax, dependencies, imports
   - Test failures: Review test assertions and expected behavior
   - Lint errors: Run local linters (`nix fmt`, `statix check`)
   - Type errors: Check type annotations and inference
5. Fix the issue in the codebase
6. Verify fix locally:
   - `nix flake check` for Nix projects
   - Run the specific failing command locally
7. Stage and commit the fix with message: `fix(ci): <description>`
8. Push and verify CI passes

## Notes

- Always verify fixes locally before pushing
- If multiple checks fail, fix them in order of dependency
- For flaky tests, investigate root cause rather than retry

$ARGUMENTS
