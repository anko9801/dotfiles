#!/bin/bash
set -eu

if [ "$(id -u)" -ne 0 ]; then
  echo "Run with sudo to configure the Determinate Nix daemon." >&2
  exit 1
fi

config_file=/etc/nix/nix.custom.conf
start_marker='# BEGIN dotfiles resource limits'
end_marker='# END dotfiles resource limits'
temporary=$(mktemp /etc/nix/nix.custom.conf.XXXXXX)
trap 'rm -f "$temporary"' EXIT

if [ -e "$config_file" ]; then
  awk -v start="$start_marker" -v end="$end_marker" '
    $0 == start { managed = 1; next }
    $0 == end { managed = 0; next }
    !managed { print }
  ' "$config_file" >"$temporary"
fi
cat >>"$temporary" <<'EOF'
# BEGIN dotfiles resource limits
max-jobs = 1
cores = 2
max-substitution-jobs = 4
eval-cores = 1
# END dotfiles resource limits
EOF

if ! cmp -s "$temporary" "$config_file"; then
  if [ -e "$config_file" ]; then
    cp -p "$config_file" "$config_file.before-dotfiles-limits"
  fi
  chmod 644 "$temporary"
  mv "$temporary" "$config_file"
  echo "Nix daemon limits updated. Restart the daemon when no builds are running."
fi
