# Tool Selection Criteria

Guidelines for evaluating CLI tools and developer utilities for this dotfiles.

## Must Have

- [ ] **Cross-platform**: Works on Linux, macOS, (Windows optional)
- [ ] **Active maintenance**: Commits within last 6 months
- [ ] **Stability**: Stars > 1,000 or proven in production
- [ ] **Nix support**: Available in nixpkgs or easy to package

## Strong Preference

- [ ] **Rust/Go**: Fast, single binary, no runtime deps
- [ ] **Config as code**: Declarative configuration
- [ ] **Unix philosophy**: Does one thing well, composable
- [ ] **POSIX compatible**: For shells and core utils

## Rejection Criteria

- Non-POSIX shells (breaks existing scripts)
- Overlapping functionality with adopted tools
- Heavy runtime dependencies (JVM, etc.)
- Unmaintained (no commits > 1 year)
- Poor Nix integration

## Adopted Tools

| Category | Tool | Stars | Reason |
|----------|------|-------|--------|
| Git TUI | lazygit | 72k | Best Git TUI, intuitive |
| Git worktree | lazyworktree | - | HM module available |
| File manager | yazi | 32k | Fast, Vim-like |
| Multiplexer | zellij | 29k | Modern tmux alternative |
| Terminal | ghostty | - | Fast, Zig-based |
| Diff | delta | 25k | Beautiful git diffs |
| ls | eza | 12k | Icons, git integration |
| cat | bat | 50k | Syntax highlighting |
| grep | ripgrep | 50k | Fast, respects gitignore |
| find | fd | 35k | Intuitive syntax |
| cd | zoxide | 25k | Smart directory jumping |
| fuzzy | fzf | 67k | Universal fuzzy finder |
| versions | mise | 12k | Replaces asdf, fast |

## Rejected Tools

| Tool | Reason |
|------|--------|
| nushell | Not POSIX compatible |
| chezmoi | Using home-manager instead |
| gitui | Already have lazygit |
| starship (fish) | Using for zsh only, fish has own prompt |

## Candidates (Under Evaluation)

| Tool | Stars | Description | Concerns |
|------|-------|-------------|----------|
| gh-dash | 10k | GitHub PR/Issue TUI | Overlaps with `gh` CLI? |
| dotenvx | 3k | Encrypted .env management | Need to evaluate workflow |

## Evaluation Process

1. Check star count and maintenance status
2. Verify Nix package availability
3. Test cross-platform compatibility
4. Compare with existing tools for overlap
5. Evaluate learning curve vs benefit
6. Add to candidates, test for 1 week
7. Move to adopted or rejected with reason
