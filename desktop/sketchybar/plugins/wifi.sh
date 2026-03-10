#!/bin/bash

IP=$(ipconfig getifaddr en0 2>/dev/null)

if [ -z "$IP" ]; then
  sketchybar --set $NAME icon="󰖪" label="Off"
  sketchybar --set wifi.hostname label="--" \
    --set wifi.ip label="--" \
    --set wifi.router label="--"
else
  sketchybar --set $NAME icon="󰖩" label="$IP"

  HOSTNAME=$(hostname -s 2>/dev/null)
  ROUTER=$(netstat -rn 2>/dev/null | awk '/default.*en0/ {print $2; exit}')

  sketchybar --set wifi.hostname label="${HOSTNAME:-N/A}" \
    --set wifi.ip label="$IP" \
    --set wifi.router label="${ROUTER:-N/A}"
fi
