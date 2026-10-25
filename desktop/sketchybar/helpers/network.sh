#!/bin/sh
set -eu
export LC_ALL=C

if [ -x "$HOME/.local/bin/desktop-network" ]; then
  exec "$HOME/.local/bin/desktop-network"
fi

route_info=$(/sbin/route -n get default 2>/dev/null || /sbin/route -n get -inet6 default 2>/dev/null || true)
interface=$(printf '%s\n' "$route_info" | /usr/bin/awk '/interface:/ {print $2; exit}')
if [ -z "$interface" ]; then
  printf 'offline\n'
  exit 0
fi
gateway=$(printf '%s\n' "$route_info" | /usr/bin/awk '/gateway:/ {print $2; exit}')
address=$(/sbin/ifconfig "$interface" 2>/dev/null | /usr/bin/awk '
  $1 == "inet" {print $2; found = 1; exit}
  $1 == "inet6" && $2 !~ /^fe80:/ {v6 = $2}
  END {if (!found && v6 != "") print v6}
')
counters=$(/usr/sbin/netstat -ibn -I "$interface" 2>/dev/null | /usr/bin/awk '
  $3 ~ /^<Link#/ {print $7, $10; exit}
')
printf '%s\n%s\n%s\n%s\n' "$interface" "${address:-Unknown}" "${gateway:-Unknown}" "$counters"
