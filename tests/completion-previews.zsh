#!/bin/zsh -f
set -eu
LS_COLORS=''
XDG_CACHE_HOME=/tmp
TMUX=''
zsh-defer() { "$@" || true }
source shell/zsh/completion.zsh
for tool in nix-shell nix-build make brew-install cargo-install npm-install pnpm-add bun-add mise-install mise-use kubectl terraform-plan; do
  zstyle -s ":fzf-tab:complete:${tool}:argument-1" fzf-preview preview
  if [[ "$preview" != 'printf "%s\n" "$word"' ]]; then
    print -u2 "Expensive preview for $tool: $preview"
    exit 1
  fi
done
print 'Candidate previews avoid Nix evaluation, remote searches, and build tools'
