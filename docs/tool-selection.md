# Tool Selection Criteria

Guidelines for evaluating CLI tools and developer utilities.

## Philosophy: Cognitive Load Reduction

Productivity = reducing cognitive load (memory allocation for tasks).
Lower cognitive load → deeper thinking about core problems.

**Principles:**
- Declarative over procedural (state desired outcome, not steps)
- Functional paradigms over imperative
- One-command deployment for psychological assurance

## Evaluation Criteria

Evaluate in priority order (earlier criteria outweigh later ones):

1. **Simplicity** — "Simple is not Easy"
   - Fewer concepts to learn, intuitive interface
   - Avoid tools that seem easy but hide complexity
   - When comparing: which features do you actually need?

2. **Reliability** — Few bugs, many users
   - Community validation reduces risk
   - Active maintenance, responsive to issues
   - Stars > 5,000 preferred (proven adoption)

3. **Cross-platform** — Linux, macOS, (Windows)
   - Must work across personal/work machines
   - Nix package available

4. **Performance** — No friction in daily workflow
   - Startup time matters (shells, prompts)
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
| Shell | zsh | POSIX compatible (LLM friendly), mature ecosystem |
| Navigation | zoxide | Flexible categorization, no new vocabulary |
| Git diff | delta, difftastic | Syntax-aware diffs |
| Git commit | czg | Interactive conventional commits |
| Git merge | zdiff3 | Shows common ancestor in conflicts |
| Git TUI | lazygit | Worktree, customCommands (czg), intuitive |
| Git worktree | git-wt, lazyworktree | CLI + TUI for worktree |
| Versions | mise | Declarative, replaces asdf/nvm/pyenv |
| Files | yazi | Fast, Vim-like file manager |
| Terminal | zellij | Session management, visible keybindings |

### Rejected

| Tool | Reason |
|------|--------|
| Fish | Not POSIX — LLMs make mistakes |
| Nushell | Not POSIX — requires script rewriting |
| chezmoi | Using home-manager (declarative Nix) |
| gitui | No worktree; no customCommands |
| gitu | No worktree; non-ASCII crash (#384) |
| ghq | zoxide covers navigation; rigid naming |

### Candidates

| Tool | Status |
|------|--------|
| gh-dash | Evaluate: cognitive load vs `gh` CLI |
