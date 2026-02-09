---
name: improve-from-reference
description: Analyze an article, blog post, or repository URL to find improvements for the current dotfiles. Use when user shares a reference and wants to incorporate best practices.
---

# Improve from Reference Skill

Thoroughly analyze external references (articles, repositories, configs) and identify improvements for this dotfiles setup.

## Process

1. **Fetch and analyze reference**:
   - Use WebFetch for articles/blog posts
   - Use `gh` CLI or WebFetch for GitHub repositories
   - Extract all relevant Nix/Home Manager configurations, patterns, and techniques

2. **Compare with current setup**: Read the current configuration files:
   - `flake.nix` - Flake structure and inputs
   - `system/` - Platform-specific builders
   - `home/` - Home Manager modules
   - `theme/` - Stylix configuration

3. **Identify improvements**: Look for:
   - Missing useful flake inputs (e.g., nixvim, sops-nix, agenix)
   - Better module organization patterns
   - Useful Home Manager options not currently used
   - Performance optimizations (e.g., nix cache settings)
   - Security improvements
   - New tools or integrations worth adding
   - Theme/styling enhancements

4. **Prioritize findings**: Categorize improvements by:
   - **High value**: Significant benefit, easy to implement
   - **Medium value**: Good benefit, moderate effort
   - **Low value**: Nice to have, can defer

5. **Create detailed plan**: For each improvement:
   - What it does and why it's valuable
   - Which files need to be modified
   - The specific Nix code changes
   - Any new dependencies or inputs required

6. **Request approval**: Use EnterPlanMode to present the plan and get user approval

7. **Apply changes**:
   - Implement approved improvements
   - Run `nix run .#fmt` to format
   - Test with `nix run .#build`

## Output Format

Present findings as:

```
## Improvements Found

### High Value
1. **[Name]**: [Description]
   - Files: [list of files]
   - Effort: [low/medium/high]

### Medium Value
...

### Already Implemented
- [Things the reference has that we already have]
```

## Important

- Don't blindly copy - adapt patterns to fit this project's structure
- Prefer Home Manager options over raw config files
- Keep the minimal/clean aesthetic of this template
- Test that changes work with `nix run .#build` before committing
