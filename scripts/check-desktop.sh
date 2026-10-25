#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

python3 tests/nix-safe.py
python3 tests/kanata-start.py
zsh -f tests/completion-previews.zsh
zsh -f tests/zsh-completion.zsh
for test in tests/sketchybar-*.lua; do
  [[ $test == *-harness.lua ]] || lua "$test"
done
