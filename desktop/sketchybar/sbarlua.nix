{ pkgs }:
pkgs.sbarlua.overrideAttrs (old: {
  patches = (old.patches or [ ]) ++ [ ./patches/bounded-client.patch ];
  nativeBuildInputs = [ pkgs.pkg-config ];
  buildPhase = ''
    runHook preBuild
    $CC -std=c99 -O2 -shared -fPIC $(pkg-config --cflags lua) \
      src/*.c $(pkg-config --libs lua) -framework CoreFoundation -o sketchybar.so
    runHook postBuild
  '';
  installPhase = ''
    runHook preInstall
    mkdir -p "$out/lib/lua/${pkgs.lua55Packages.lua.luaversion}"
    cp sketchybar.so "$out/lib/lua/${pkgs.lua55Packages.lua.luaversion}/"
    runHook postInstall
  '';
  doCheck = true;
  checkPhase = ''
    runHook preCheck
    $CC -O2 -Isrc $(pkg-config --cflags lua) ${../../tests/sbarlua-state.c} \
      src/parsing.c src/cJSON.c $(pkg-config --libs lua) -framework CoreFoundation -o test-state
    ./test-state
    $CC -O2 -Isrc ${../../tests/sbarlua-ipc.c} -framework CoreFoundation -o test-ipc
    ./test-ipc
    runHook postCheck
  '';
})
