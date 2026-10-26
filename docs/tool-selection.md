# Tool Selection

Summary of tool decisions. See [ergonomics.md](ergonomics.md) for the unified philosophy.

## Philosophy

Single principle: **Ergonomics (Human Factors)** — reduce human burden.

| Domain | Document | Core Idea |
|--------|----------|-----------|
| Root | [ergonomics.md](ergonomics.md) | Unified principle: reduce burden |
| Physical | [keybinding-design.md](keybinding-design.md) | RSI prevention, home row mods |
| Cognitive | [flow-state.md](flow-state.md) | Minimize interruptions |
| Cognitive | [posix-compatibility.md](posix-compatibility.md) | LLM-friendly syntax |
| Cognitive | [declarative.md](declarative.md) | State desired outcome |
| Cognitive | [unix-philosophy.md](unix-philosophy.md) | Do one thing well |
| Research | [beyond-nix.md](beyond-nix.md) | IaC alternatives |

## Evaluation Criteria

Evaluate in priority order (earlier criteria outweigh later ones):

1. **Physical Ergonomics** — RSI prevention, home row priority
2. **Security** — peace of mind, E2EE, no plaintext secrets
3. **Cognitive Load** — fewer concepts, intuitive interface
4. **Flow State** — no friction (shell ≤200ms startup)
5. **Portability** — Linux, macOS, Nix package available

## Adopted

| Category | Tool | Rationale |
|----------|------|-----------|
| Shell | zsh | LLM compatible, plugins match Fish UX |
| Navigation | zoxide | No new vocabulary, `cd` alias |
| Git diff | delta, difftastic | Syntax-aware, readable |
| Git commit | czg | Interactive conventional commits |
| Git merge | zdiff3 | Shows common ancestor |
| Git TUI | lazygit | Worktree, customCommands, intuitive |
| Git worktree | git-wt, lazyworktree | CLI + TUI, fast switching |
| Versions | mise | Interactive activation once; shims for scripts/IDEs; explicit installs on macOS |
| Files | yazi | Fast, Vim-like, focused |
| Multiplexer | herdr | Agent state in the sidebar; self-managed binary |
| Secrets | 1Password | E2EE, biometric, peace of mind |
| Theme | Stylix + Catppuccin | Unified colors across tools |
| macOS windows | AeroSpace | Keyboard navigation; explicit shared workspace list; cached bar membership during focus changes; see [measurements](aerospace-performance.md) |
| macOS status | SketchyBar + SbarLua | Bounded native IPC, visible app locations and graphs, native AppKit detail menus; [stability](sketchybar-stability.md) |
| macOS calendar | AppKit + EventKit, Itsycal | A fixed-width popover anchored below the date with month navigation and synced agenda; Itsycal is a secondary detailed view; [integration](sketchybar-stability.md#calendar) |
| macOS keyboard | Kanata + native Caps Lock mapping | Check virtual-driver readiness before startup; avoid repeated failures while approval is pending |
| Dotfiles | home-manager | Reproducible CLI/config; macOS GUI tools stay in Homebrew. See [macOS performance](macos-performance.md). |

## Rejected

| Tool | Reason |
|------|--------|
| Fish, Nushell | Not POSIX — LLM assistance fails |
| chezmoi, yadm | Config-only; home-manager unifies packages + config |
| Ansible | Procedural; fewer roles than Nix packages |
| gitui | No worktree; no customCommands |
| gitu | No worktree; non-ASCII crash |
| ghq | Forces rigid naming; zoxide is vocabulary-free |
| nvm, asdf | Slow shell startup; mise is faster |
| Oh-My-Zsh | Slow startup; zinit/zim are faster |

## Candidates

| Tool | Status |
|------|--------|
| Atuin | Shell history sync, fast search |
| zsh-you-should-use | Alias reminder, accelerates learning |
| tldr | Example-focused man alternative |
| Starship | Cross-shell prompt, active maintenance |
