#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
[[ $(uname -s) == Darwin ]] || exit 0
output=$(mktemp -d)
trap 'rm -rf "$output"' EXIT
frameworks=(-framework AppKit -framework CoreAudio -framework AudioToolbox -framework EventKit)
calendar_sources=(desktop/sketchybar/helpers/calendar-{events,view,popover,editor}.m)
/usr/bin/xcrun clang -fobjc-arc -O2 -Wall -Wextra tests/menu-native.m "${frameworks[@]}" -o "$output/view"
/usr/bin/xcrun clang -fobjc-arc -O2 -Wall -Wextra \
  desktop/sketchybar/helpers/menu-server.m desktop/sketchybar/helpers/menu-view.m \
  "${calendar_sources[@]}" "${frameworks[@]}" -o "$output/server"
/usr/bin/xcrun clang -O2 -Wall -Wextra desktop/sketchybar/helpers/menu-client.c \
  -framework CoreFoundation -o "$output/client"
"$output/view"
/usr/bin/xcrun clang -fobjc-arc -O2 -Wall -Wextra tests/calendar-native.m \
  "${calendar_sources[@]}" "${frameworks[@]}" -o "$output/calendar"
"$output/calendar"
python3 tests/menu-ipc.py "$output/server" "$output/client"
/usr/bin/xcrun clang -std=c11 -D_DARWIN_C_SOURCE -O2 -Wall -Wextra -Werror desktop/sketchybar/helpers/metrics.c -o "$output/metrics"
/usr/bin/xcrun clang -std=c11 -O2 -Wall -Wextra -Werror -Idesktop/sketchybar/helpers \
  desktop/sketchybar/helpers/network.c -framework SystemConfiguration -framework CoreFoundation -o "$output/network"
/usr/bin/xcrun clang -std=c11 -O2 -Wall -Wextra -Werror -Idesktop/sketchybar/helpers \
  desktop/sketchybar/helpers/audio.c -framework CoreAudio -framework AudioToolbox -framework CoreFoundation -o "$output/audio"
python3 tests/desktop-metrics.py "$output/metrics" "$output/network" "$output/audio"
