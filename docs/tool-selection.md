# Tool Selection Criteria

Guidelines for evaluating CLI tools and developer utilities.

## Philosophy: Cognitive Load Reduction

Productivity = reducing cognitive load (mental effort required for tasks).
Lower cognitive load → deeper focus on core problems.

**Principles:**
- Declarative over procedural — state desired outcome, run one command
- Single Source of Truth — avoid duplication, centralize changes
- Reproducibility — consistent behavior across machines

## Evaluation Criteria

Evaluate in priority order (earlier criteria outweigh later ones):

1. **Simplicity** — "Simple is not Easy"
   - Fewer concepts to learn, intuitive interface
   - No new vocabulary when possible (e.g., `cd` alias over new command)
   - When comparing: which features do you actually use?

2. **Reliability** — Few bugs, many users
   - Community validation reduces risk
   - Active maintenance, responsive to issues
   - Stars > 5,000 preferred

3. **Cross-platform** — Linux, macOS, (Windows)
   - Must work across personal/work machines
   - Nix package available

4. **Performance** — No friction in daily workflow
   - Startup time matters (shell ≤ 200ms)
   - Rust/Go preferred (fast, single binary)

5. **Security** — Foundation for sensitive data
   - No plain text secrets
   - Minimal attack surface

## Evaluation Process

1. Check criteria in order (simplicity → security)
2. Compare with existing tools for overlap
3. Test for 1 week in daily workflow
4. Document decision with specific rationale

**Rejection reasons must be concrete, not circular:**
- ✗ "gitui rejected because we have lazygit"
- ✓ "gitui rejected: no worktree support, no customCommands"

## Decisions

### Adopted

| Category | Tool | Rationale |
|----------|------|-----------|
| Shell | zsh | POSIX compatible (LLM friendly), modern plugins match alternatives |
| Navigation | zoxide | Free categorization, no new vocabulary (`cd` alias) |
| Git diff | delta, difftastic | Syntax-aware diffs |
| Git commit | czg | Interactive conventional commits with emoji |
| Git merge | zdiff3 | Shows common ancestor in conflicts |
| Git TUI | lazygit | Worktree, customCommands (czg), intuitive |
| Git worktree | git-wt, lazyworktree | CLI + TUI for worktree |
| Versions | mise | Declarative, replaces asdf/nvm/pyenv |
| Files | yazi | Fast, Vim-like file manager |
| Terminal | zellij | Session management, visible keybindings |
| Secrets | 1Password | E2EE, biometric unlock, keys never on disk |
| Theme | Stylix + Catppuccin | Unified colors/fonts across all tools |

### Rejected

| Tool | Reason |
|------|--------|
| Fish, Nushell | Not POSIX — LLM assistance fails, requires rewrites |
| chezmoi, yadm | Config-only; home-manager unifies packages + config |
| Ansible | Procedural; fewer roles than Nix packages |
| gitui | No worktree; no customCommands |
| gitu | No worktree; non-ASCII crash (#384) |
| ghq | Forces rigid naming; zoxide allows free categorization |

### Candidates

| Tool | Status |
|------|--------|
| gh-dash | Evaluate: cognitive load vs `gh` CLI |
