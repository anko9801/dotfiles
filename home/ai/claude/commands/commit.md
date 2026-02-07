# Git Commit with Conventional Format

Create atomic, well-structured commits following conventional commit format.

## Philosophy: Revertability First

Each commit should be:
- **Atomic**: One logical change per commit
- **Revertable**: Can be reverted without breaking other changes
- **Self-contained**: Includes all related changes (code, tests, docs)

## Current State

**Status:**
```
!git status --short
```

**Staged Changes:**
```
!git diff --cached --stat
```

## Workflow

### 1. Analyze Changes

Review all staged changes and identify logical groups:
- Feature additions
- Bug fixes
- Refactoring
- Documentation updates
- Style/formatting changes

### 2. Split if Necessary

If changes span multiple concerns, split into separate commits:

**File-level splitting:**
```bash
git reset HEAD  # Unstage all
git add <specific-files>  # Stage first logical group
git commit -m "type(scope): message"
# Repeat for remaining groups
```

**Hunk-level splitting** (for mixed changes in single file):
```bash
# Extract specific hunks using git diff and apply
git diff HEAD -- file.ext > /tmp/all-changes.patch
# Edit patch to keep only relevant hunks
git checkout HEAD -- file.ext  # Reset file
git apply /tmp/selected-hunks.patch  # Apply specific changes
git add file.ext
git commit -m "type(scope): message"
```

### 3. Commit Format

```
type(scope): subject

[optional body]

[optional footer]
Assisted-by: Claude (model: <model-name>)
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation only
- `style`: Formatting, no code change
- `refactor`: Code change that neither fixes nor adds
- `perf`: Performance improvement
- `test`: Adding or fixing tests
- `chore`: Maintenance, dependencies
- `ci`: CI/CD changes
- `build`: Build system changes

**Subject rules:**
- Imperative mood ("add" not "added")
- No period at end
- Max 50 characters
- Lowercase first letter

### 4. Pre-commit Verification

Before committing, verify:
```bash
nix fmt  # Format code
statix check .  # Nix linting
deadnix .  # Dead code detection
```

## Examples

**Single concern:**
```
feat(shell): add tcode command for 3-pane dev layout

Assisted-by: Claude (model: claude-opus-4-5-20251101)
```

**Breaking change:**
```
feat(api)!: change authentication to use JWT

BREAKING CHANGE: API now requires Bearer token instead of API key

Assisted-by: Claude (model: claude-opus-4-5-20251101)
```

$ARGUMENTS
