# Tool Selection

Document your tool decisions here. Having clear rationale helps LLMs make better suggestions.

## Evaluation Criteria

Evaluate in priority order (earlier criteria outweigh later ones):

1. **Physical Ergonomics** — RSI prevention, home row priority
2. **Security** — peace of mind, no plaintext secrets
3. **Cognitive Load** — fewer concepts, intuitive interface
4. **Flow State** — no friction (shell ≤200ms startup)
5. **Portability** — Linux, macOS, Nix package available

## Adopted

| Category | Tool | Rationale |
|----------|------|-----------|
| Shell | bash | Universal, POSIX compatible |
| Prompt | starship | Cross-shell, fast, informative |
| Editor | vim | Ubiquitous, modal editing |
| Dotfiles | home-manager | Packages + config unified |
| Theme | Stylix + Catppuccin | Unified colors across tools |

## Rejected

| Tool | Reason |
|------|--------|

## Candidates

| Tool | Status |
|------|--------|
| zsh | Fish-like plugins with POSIX compatibility |
| tmux/zellij | Terminal multiplexer |
| neovim/nixvim | Extensible editor with Nix integration |
