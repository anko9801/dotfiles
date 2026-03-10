---
description: Handle GitHub PR review comments by implementing fixes or providing explanations
argument-hint: <github-pr-comment-url>
allowed-tools: Bash(gh:*), Bash(git:*), Read, Edit
---

# PR Review Responder

Handle GitHub PR review comments from the provided URL.

## Input

`$ARGUMENTS` - GitHub PR comment URL

## Context

Current branch: !`git branch --show-current`
Repository: !`gh repo view --json nameWithOwner --jq .nameWithOwner`

## Process

1. **Retrieve** - Extract PR number and comment ID from URL, fetch via GitHub API
2. **Analyze** - Parse comment, determine if code changes are needed
3. **Act** - Fix if needed, or explain why no changes are needed
4. **Respond** - Concise explanation of actions taken

## URL Patterns

- `https://github.com/{owner}/{repo}/pull/{pr}#issuecomment-{id}`
- `https://github.com/{owner}/{repo}/pull/{pr}#discussion_r{id}`
- `https://github.com/{owner}/{repo}/pull/{pr}/files#r{id}`

## Response Format

### Fix applied
```
> [review comment]
Fixed. [specific change description]
```

### No fix needed
```
> [review comment]
No change needed. [technical reason]
```

## Constraints

- Brief, technical responses
- Focus on the specific concern
- One comment at a time

Process the URL: $ARGUMENTS
