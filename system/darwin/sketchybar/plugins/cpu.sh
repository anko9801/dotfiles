#!/bin/bash

source "$HOME/.config/sketchybar/plugins/colors.sh"

CPU=$(ps -A -o %cpu | awk '{s+=$1} END {printf "%.0f", s}')
CPU_PERCENT=$(awk "BEGIN {v=$CPU/150; if(v>1) v=1; printf \"%.2f\", v}")

# Dynamic color based on load
if [ "$CPU" -gt 80 ]; then
  COLOR=$RED
elif [ "$CPU" -gt 60 ]; then
  COLOR=$PEACH
elif [ "$CPU" -gt 30 ]; then
  COLOR=$YELLOW
else
  COLOR=$SKY
fi

sketchybar --set $NAME icon="󰻠" label="${CPU}%" icon.color="$COLOR" label.color="$COLOR" \
  --set cpu_graph graph.color="$COLOR" \
  --set cpu_bracket background.border_color="$COLOR" \
  --push cpu_graph "$CPU_PERCENT"
