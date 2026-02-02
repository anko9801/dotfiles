# Agent Compliance Requirements

All AI agents **MUST** adhere to the following standards.

## Core Principles

- **Understand context first**: Check changed files and documents before acting
- **Code like Kent Beck**: Simple, clear, refactor often
- **Explain why, not what**: Only comment non-obvious decisions

## Code Artifacts

- **English only**: All comments, commits, and code must be in English
- **No auto-commits**: Output checkpoint messages; let user decide
- **Nix formatting**: Run `nix fmt` before suggesting changes
- **Linting**: Run `statix check` and `deadnix` for Nix files

## Commit Messages

- **Conventional Commits**: `<type>(<scope>): <subject>`
- **Types**: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `chore`
- **Breaking changes**: `<type>!: <subject>`
- **Trailer**: `Assisted-by: {{agent name}} (model: {{model name}})`

## Project-Specific

- Prefer `programs.*` over raw `home.packages`
- Keep modules under 400 lines
- Test with `nix flake check`
