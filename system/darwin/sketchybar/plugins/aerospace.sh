#!/bin/bash

source "$HOME/.config/sketchybar/plugins/colors.sh"
source "$HOME/.config/sketchybar/plugins/icon_map.sh"

SID="$1"
COLOR="$2"

# Refresh app icons for this workspace
app_icons=""
app_names=""
while IFS= read -r app; do
  [ -z "$app" ] && continue
  icon_map "$app"
  if [ "$icon_result" = ":default:" ]; then
    app_names+="$app "
  else
    app_icons+="$icon_result "
  fi
done <<<"$(aerospace list-windows --workspace "$SID" --format '%{app-name}' 2>/dev/null | sort -u)"

display_icon="$SID"
[ -n "$app_names" ] && display_icon="$SID $app_names"

if [ "$SID" = "$FOCUSED_WORKSPACE" ]; then
  sketchybar --set $NAME \
    background.drawing=on \
    background.color="$COLOR" \
    icon="$display_icon" \
    icon.color=$BLACK \
    label="$app_icons" \
    label.color=$BLACK
else
  sketchybar --set $NAME \
    background.drawing=off \
    icon="$display_icon" \
    icon.color="$COLOR" \
    label="$app_icons" \
    label.color="$COLOR"
fi
