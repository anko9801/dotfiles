# Tool Selection Criteria

Guidelines for evaluating CLI tools and developer utilities.

## Philosophy: Cognitive Load Reduction (認知負荷の削減)

Productivity = reducing cognitive load (memory allocation for tasks).
Lower cognitive load → deeper thinking about core problems.

**Principles:**
- Declarative over procedural (state desired outcome, not steps)
- Functional paradigms over imperative
- One-command deployment for psychological assurance
- Avoid manual scripts (idempotency, cross-platform burden)

## Priority Order

Evaluate tools in this order:

1. **Simplicity** — "Simple is not Easy"
   - True simplicity requires thoughtful design
   - Fewer concepts to learn, intuitive interface
   - Avoid tools that seem easy but hide complexity

2. **Reliability** — Few bugs, many users
   - Community validation reduces risk
   - Active maintenance, responsive to issues
   - Stars > 5,000 preferred (proven adoption)

3. **Cross-platform** — Linux, macOS, (Windows)
   - Must work across personal/work machines
   - Containers, cloud, Raspberry Pi compatibility
   - Nix package available

4. **Performance** — No friction in daily workflow
   - Startup time matters (shells, prompts)
   - Rust/Go preferred (fast, single binary)

5. **Security** — Foundation for sensitive data
   - No plain text secrets
   - Minimal attack surface

## Shell & POSIX Compatibility

**Requirement:** POSIX-compatible shells only.

**Reason:** LLMs make fewer errors with POSIX syntax. Non-POSIX shells (Fish, Nushell) require rewriting scripts and increase AI-assisted coding friction.

**Choice:** Zsh — mature plugin ecosystem, POSIX compatible, equivalent UX to alternatives.

## Tool Decisions

### Adopted

| Category | Tool | Rationale |
|----------|------|-----------|
| Shell | zsh | POSIX compatible, LLM friendly |
| Navigation | zoxide | Flexible categorization, no new vocabulary |
| Git diff | delta, difftastic | Syntax-aware, reduces cognitive load |
| Git commit | czg | Interactive conventional commits |
| Merge | zdiff3 | Shows common ancestor in conflicts |
| Versions | mise | Declarative, replaces asdf/nvm/pyenv |
| Files | yazi | Fast, Vim-like, replaces GUI file manager |
| Terminal | zellij | Session management, visible keybindings |
| Git TUI | lazygit | Intuitive, reduces git command memorization |

### Rejected

| Tool | Reason |
|------|--------|
| Fish | Not POSIX — LLMs make mistakes |
| Nushell | Not POSIX — requires rewriting |
| chezmoi | Using home-manager (declarative Nix) |
| gitui | Same role as lazygit — multiple tools for same task increases cognitive load |
| ghq | zoxide covers navigation; ghq forces rigid naming convention |
| Manual scripts | Idempotency/cross-platform burden |

### Candidates

| Tool | Evaluation |
|------|------------|
| gh-dash | Does it reduce cognitive load vs `gh` CLI? |

## Evaluation Process

1. Does it reduce cognitive load?
2. Check priority criteria (simplicity → security)
3. Verify POSIX compatibility (if shell-related)
4. Compare with existing tools for overlap
5. Test for 1 week in daily workflow
6. Document decision with rationale
