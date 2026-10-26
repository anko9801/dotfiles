#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
[[ $(uname -s) == Darwin ]] || exit 0
output=$(mktemp -d)
trap 'rm -rf "$output"' EXIT
frameworks=(-framework AppKit -framework CoreAudio -framework AudioToolbox)
/usr/bin/xcrun clang -fobjc-arc -O2 -Wall -Wextra tests/menu-native.m "${frameworks[@]}" -o "$output/view"
/usr/bin/xcrun clang -fobjc-arc -O2 -Wall -Wextra \
  desktop/sketchybar/helpers/menu-server.m desktop/sketchybar/helpers/menu-view.m \
  "${frameworks[@]}" -o "$output/server"
/usr/bin/xcrun clang -O2 -Wall -Wextra desktop/sketchybar/helpers/menu-client.c \
  -framework CoreFoundation -o "$output/client"
"$output/view"
python3 tests/menu-ipc.py "$output/server" "$output/client"
