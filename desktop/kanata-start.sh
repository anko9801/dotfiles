#!/bin/sh
set -eu
export LC_ALL=C

kanata_bin=${1:?Kanata executable required}
config_path=${2:?Configuration path required}
extensions_command=${KANATA_SYSTEMEXTENSIONSCTL:-/usr/bin/systemextensionsctl}
launchctl_command=${KANATA_LAUNCHCTL:-/bin/launchctl}

if [ ! -x "$kanata_bin" ] || [ ! -r "$config_path" ]; then
  echo 'Kanata not started: executable or configuration unavailable.' >&2
  exit 0
fi

if ! extensions=$("$extensions_command" list); then
  echo 'Kanata not started: cannot inspect virtual keyboard driver.' >&2
  exit 0
fi

if ! printf '%s\n' "$extensions" | /usr/bin/awk '
  $1 == "*" && $2 == "*" && $4 == "org.pqrs.Karabiner-DriverKit-VirtualHIDDevice" && /\[activated enabled\]/ {ready = 1}
  END {exit !ready}
'; then
  echo 'Kanata not started: virtual keyboard driver is not enabled and active.' >&2
  exit 0
fi

if ! service_status=$("$launchctl_command" print system/org.pqrs.service.daemon.Karabiner-VirtualHIDDevice-Daemon 2>/dev/null) ||
  ! printf '%s\n' "$service_status" | /usr/bin/awk '
    $1 == "state" && $2 == "=" && $3 == "running" {ready = 1}
    END {exit !ready}
  '; then
  echo 'Kanata not started: virtual keyboard output service is not running.' >&2
  exit 0
fi

if ! "$kanata_bin" --quiet --check --no-wait -c "$config_path"; then
  echo 'Kanata not started: configuration validation failed.' >&2
  exit 0
fi

exec "$kanata_bin" --quiet --no-wait -c "$config_path"
