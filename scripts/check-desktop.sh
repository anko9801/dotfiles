#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

while IFS= read -r -d '' file; do
  "${NIX_INSTANTIATE:-nix-instantiate}" --parse "$file" >/dev/null
done < <(git ls-files -z '*.nix')

python3 tests/nix-safe.py
python3 tests/apply-sketchybar.py
python3 tests/kanata-start.py
zsh -f tests/completion-previews.zsh
zsh -f tests/zsh-completion.zsh
for test in tests/sketchybar-*.lua; do
  [[ $test == *-harness.lua ]] || lua "$test"
done
