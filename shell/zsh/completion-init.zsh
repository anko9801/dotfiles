_init_completion() {
  setopt localoptions extendedglob
  local dump="${ZDOTDIR:-$HOME}/.zcompdump"
  local audit_stamp="$dump.audited"
  autoload -Uz compinit
  if [[ -s "$dump" && -n "$audit_stamp"(#qN.mh-24) ]]; then
    compinit -C -d "$dump"
  elif compinit -d "$dump"; then
    command touch "$audit_stamp"
  fi
}
