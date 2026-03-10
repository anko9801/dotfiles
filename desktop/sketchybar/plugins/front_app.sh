#!/bin/bash

source "$CONFIG_DIR/plugins/icon_map.sh"

if [ "$SENDER" = "front_app_switched" ]; then
  icon_map "$INFO"
  sketchybar --set $NAME icon="$icon_result" label="$INFO"
fi
