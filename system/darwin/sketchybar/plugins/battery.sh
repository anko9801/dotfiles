#!/bin/bash

BATT_INFO=$(pmset -g batt)
PERCENTAGE=$(echo "$BATT_INFO" | grep -Eo '\d+%' | head -1)
CHARGING=$(echo "$BATT_INFO" | grep -c 'AC Power')
CHARGE=${PERCENTAGE%\%}
REMAINING=$(echo "$BATT_INFO" | grep -Eo '\d+:\d+' | head -1)

if [ "$CHARGING" -gt 0 ]; then
  ICON="󰂄"
elif [ "$CHARGE" -gt 80 ]; then
  ICON="󰁹"
elif [ "$CHARGE" -gt 60 ]; then
  ICON="󰂀"
elif [ "$CHARGE" -gt 40 ]; then
  ICON="󰁾"
elif [ "$CHARGE" -gt 20 ]; then
  ICON="󰁻"
else
  ICON="󰁺"
fi

sketchybar --set $NAME icon="$ICON" label="$PERCENTAGE"

# Update popup with remaining time
if [ -n "$REMAINING" ] && [ "$REMAINING" != "0:00" ]; then
  sketchybar --set battery.remaining label="$REMAINING remaining"
elif [ "$CHARGING" -gt 0 ]; then
  sketchybar --set battery.remaining label="Charging"
else
  sketchybar --set battery.remaining label="Calculating..."
fi
