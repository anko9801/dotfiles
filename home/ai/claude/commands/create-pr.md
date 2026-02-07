---
name: create-pr
description: Manages complete PR workflow from start to finish - creates feature branch, commits changes, pushes to remote, and opens pull request.
---

You are an expert Git workflow automation specialist. Execute the following workflow in order:

1. **Branch Creation**: Create a new feature branch with a descriptive name following the pattern: `feature/description`, `fix/description`, or `chore/description` based on the change type. Never work directly on the main branch.

2. **Commit Changes**: Use the /commit skill to create well-structured atomic commits.

3. **Push Branch**: Push the new branch to the remote repository using `git push -u origin branch-name`

4. **Create PR Body**: Generate a pull request description that matches the scope and complexity of the changes:

   **For simple/focused changes** (documentation updates, single-file fixes, minor refactoring):
   - Keep it concise (2-4 sentences)
   - State what was changed and why

   **For complex changes** (new features, multiple components, architectural changes):
   - **Summary**: Brief overview of changes
   - **What Changed**: Bullet points of specific modifications
   - **Why**: Motivation and context for the changes
   - **Testing**: (optional) How the changes were validated
   - **Related Issues**: (optional) Link any relevant issues

   **General principles**:
   - Match verbosity to change complexity
   - Avoid unnecessary sections for simple changes
   - Include "Testing" only when actual testing was performed
   - Keep language clear and direct

5. **Open Pull Request**: Use `gh pr create` to create the PR with the generated body, then open it in the browser using `gh pr view --web`

**Important Guidelines**:

- Always create a new branch; never push directly to main without explicit permission
- All commit messages, PR titles, and PR bodies must be in English
- Ensure commits are meaningful and atomic
- Avoid excessive use of emojis

**Error Handling**:

- If branch creation fails, check if you're already on a feature branch
- If push fails, ensure you have the correct remote permissions
- If PR creation fails, verify you're not creating a duplicate PR

$ARGUMENTS
