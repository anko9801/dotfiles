#!/bin/bash

source "$HOME/.config/sketchybar/plugins/colors.sh"

MEMORY=$(vm_stat | awk '
  /Pages active/ {a=$3}
  /Pages wired/ {w=$4}
  /Pages speculative/ {s=$3}
  END {
    gsub(/\./,"",a); gsub(/\./,"",w); gsub(/\./,"",s)
    printf "%.0f", (a+w+s)*4096/1024/1024/1024
  }
')
TOTAL=$(sysctl -n hw.memsize | awk '{printf "%.0f", $1/1024/1024/1024}')
PERCENT=$((MEMORY * 100 / TOTAL))
MEM_PERCENT=$(awk "BEGIN {v=$PERCENT/150; if(v>1) v=1; printf \"%.2f\", v}")

# Dynamic color based on usage
if [ "$PERCENT" -gt 80 ]; then
  COLOR=$RED
elif [ "$PERCENT" -gt 60 ]; then
  COLOR=$PEACH
elif [ "$PERCENT" -gt 30 ]; then
  COLOR=$YELLOW
else
  COLOR=$TEAL
fi

sketchybar --set $NAME icon="󰍛" label="${PERCENT}%" icon.color="$COLOR" label.color="$COLOR" \
  --set mem_graph graph.color="$COLOR" \
  --set mem_bracket background.border_color="$COLOR" \
  --push mem_graph "$MEM_PERCENT"
