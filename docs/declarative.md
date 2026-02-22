# Declarative Management

Part of [Cognitive Ergonomics](ergonomics.md#cognitive-ergonomics).

Declare desired state, run one command, system converges.

## Declarative vs Procedural

| Approach | Example | Cognitive Load |
|----------|---------|----------------|
| Procedural | "Install X, then configure Y, then link Z" | High — remember steps |
| Declarative | "I want X with config Y" | Low — state desired outcome |

## Principles

- **Single Source of Truth** — avoid duplication, centralize changes
- **Reproducibility** — same input = same output across machines
- **One-command deployment** — psychological assurance

## References

- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [mise Documentation](https://mise.jdx.dev/)
