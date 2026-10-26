{ pkgs }:
let
  inherit (pkgs.lua55Packages) lua;
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
  inherit metrics processStamp;
}
