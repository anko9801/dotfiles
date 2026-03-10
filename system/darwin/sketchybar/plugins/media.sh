#!/bin/bash

STATE=$(echo "$INFO" | grep -o '"state":"[^"]*"' | cut -d'"' -f4)
TITLE=$(echo "$INFO" | grep -o '"title":"[^"]*"' | cut -d'"' -f4)
ARTIST=$(echo "$INFO" | grep -o '"artist":"[^"]*"' | cut -d'"' -f4)

if [ "$STATE" = "playing" ]; then
  sketchybar --set $NAME icon="󰎆" label="$ARTIST - $TITLE" drawing=on
elif [ "$STATE" = "paused" ]; then
  sketchybar --set $NAME icon="󰏤" label="$ARTIST - $TITLE" drawing=on
else
  sketchybar --set $NAME drawing=off
fi
