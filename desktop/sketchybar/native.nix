{ pkgs }:
let
  inherit (pkgs.lua55Packages) lua;
  menu = pkgs.runCommandCC "desktop-menu" { } ''
    app="$out/Applications/SketchyBar Menu.app"
    mkdir -p "$out/bin" "$app/Contents/MacOS"
    cp ${./helpers/menu-info.plist} "$app/Contents/Info.plist"
    $CC -fobjc-arc -O2 -Wall -Wextra ${./helpers/menu-server.m} ${./helpers/menu-view.m} \
      -framework AppKit -framework CoreAudio -framework AudioToolbox -o "$app/Contents/MacOS/desktop-menu"
    $CC -O2 -Wall -Wextra ${./helpers/menu-client.c} -framework CoreFoundation -o "$out/bin/menu-client"
    cat > "$out/bin/desktop-menu" <<EOF
    #!/bin/sh
    exec /usr/bin/open -n -a "$app" --args "\$@"
    EOF
    chmod +x "$out/bin/desktop-menu"
  '';
  metrics = pkgs.runCommandCC "desktop-metrics" { } ''
    mkdir -p "$out/bin"
    cp ${./helpers/json.h} json.h
    $CC -std=c11 -O2 -Wall -Wextra ${./helpers/metrics.c} -o "$out/bin/desktop-metrics"
    $CC -std=c11 -O2 -Wall -Wextra -I. ${./helpers/network.c} \
      -framework SystemConfiguration -framework CoreFoundation -o "$out/bin/desktop-network"
    $CC -std=c11 -O2 -Wall -Wextra ${./helpers/audio.c} \
      -framework CoreAudio -framework AudioToolbox -o "$out/bin/desktop-audio"
  '';
  processStamp = pkgs.runCommandCC "sketchybar-processstamp" { buildInputs = [ lua ]; } ''
    mkdir -p "$out/lib"
    $CC -shared -O2 -Wall -Wextra -I${lua}/include \
      ${./helpers/processstamp.c} -L${lua}/lib -llua -o "$out/lib/processstamp.so"
  '';
in
{
  inherit menu metrics processStamp;
}
