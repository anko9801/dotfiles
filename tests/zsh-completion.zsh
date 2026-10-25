#!/bin/zsh -f
set -eu
setopt extendedglob
test_root=$(mktemp -d)
trap 'rm -rf "$test_root"' EXIT
export ZDOTDIR="$test_root"
source shell/zsh/completion-init.zsh
wrap_compaudit() {
  autoload -Uz compaudit
  autoload +X compaudit
  functions[compaudit]="print audit >> '$test_root/audits'; ${functions[compaudit]}"
}

wrap_compaudit
_init_completion
[[ -s "$ZDOTDIR/.zcompdump" && -f "$ZDOTDIR/.zcompdump.audited" ]]
initial=$(wc -l < "$test_root/audits")
touch -t 202001010000 "$ZDOTDIR/.zcompdump"
wrap_compaudit
_init_completion
[[ $(wc -l < "$test_root/audits") == $initial ]]
touch -t 202001010000 "$ZDOTDIR/.zcompdump.audited"
wrap_compaudit
_init_completion
[[ $(wc -l < "$test_root/audits") -gt $initial ]]
print 'Completion audit: first run, cached old dump, and daily renewal passed'
