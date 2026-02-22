# POSIX Compatibility

Part of [Cognitive Ergonomics](ergonomics.md#cognitive-ergonomics).

POSIX-compatible shells reduce friction with LLM-assisted coding.

## Why POSIX Matters

- LLMs are trained on POSIX shell syntax (bash, zsh)
- Non-POSIX shells require syntax translation
- Script portability across machines and CI

**Observation:** LLMs make fewer errors with POSIX syntax. Non-POSIX shells (Fish, Nushell) require rewriting scripts and increase AI-assisted coding friction.

## zsh as Best of Both Worlds

Modern plugins match Fish UX without leaving POSIX:

| Plugin | Provides |
|--------|----------|
| zsh-autosuggestions | Fish-style command completion |
| fzf-tab | Fuzzy completion for everything |
| zsh-fast-syntax-highlighting | Real-time syntax coloring |
| zsh-abbr | Space-triggered alias expansion |

## References

- [Why zsh over Fish](https://www.reddit.com/r/zsh/comments/pk4i7a/why_zsh_over_fish/)
- [Zsh Plugins Guide](https://www.sitepoint.com/zsh-commands-plugins-aliases-tools/)
