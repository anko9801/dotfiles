#!/bin/bash

VOLUME=$(osascript -e 'output volume of (get volume settings)')
MUTED=$(osascript -e 'output muted of (get volume settings)')

if [ "$MUTED" = "true" ] || [ "$VOLUME" -eq 0 ] 2>/dev/null; then
  ICON="󰝟"
elif [ "$VOLUME" -gt 60 ]; then
  ICON="󰕾"
elif [ "$VOLUME" -gt 30 ]; then
  ICON="󰖀"
else
  ICON="󰕿"
fi

sketchybar --set $NAME icon="$ICON" label="${VOLUME}%"

# Update popup with current output device
if command -v SwitchAudioSource &>/dev/null; then
  DEVICE=$(SwitchAudioSource -c 2>/dev/null)
  sketchybar --set volume.device label="${DEVICE:-Unknown}"
else
  sketchybar --set volume.device label="$(system_profiler SPAudioDataType 2>/dev/null | awk -F': ' '/Default Output Device: Yes/{found=1} found && /Device Name:/{print $2; exit}')"
fi
