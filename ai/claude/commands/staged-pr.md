---
description: Create a GitHub Pull Request from staged files
argument-hint: [--en]
allowed-tools: Bash(git:*), Bash(gh:*)
---

# PR Staged Files

Create a GitHub Pull Request from staged files.

## Constraints

- **Working directly on default branch (main/master) is prohibited**
- **Only process staged files**
- **Never execute `git add` or `git restore` automatically**

## Context

- Current branch: !`git branch --show-current`
- Staged changes: !`git diff --cached --stat`

## Process

1. **Branch Check**
   - If on default branch, create and switch to a new branch based on staged changes

2. **Commit**
   - Conventional commit (no scope, imperative, no punctuation)
   - Focus on "why" in the message
   - Default: Japanese, English with `--en` flag

3. **Create Pull Request**
   - Push branch to remote
   - Create PR (Japanese by default, English with `--en`)
   - Open PR in browser

4. **Code Review**
   - Review staged changes for issues or improvements

### Step 1: Get full diff

```bash
git diff --cached
```

### Step 2: Commit and push

```bash
git commit -m "[conventional commit message]"
git push -u origin "$(git branch --show-current)"
```

### Step 3: Create PR

Japanese (default):
```bash
gh pr create --title "[タイトル]" --body "## 概要
[なぜこの変更が必要か]

## 変更内容
[変更の理由と意図]" --web
```

English (with `--en`):
```bash
gh pr create --title "[title]" --body "## Summary
[Why these changes are needed]

## Changes
[Reasoning and intent]" --web
```

Arguments: $ARGUMENTS
