{ pkgs }:
let
  inherit (pkgs) lib;
  colors =
    (import ../../theme/catppuccin-mocha.nix { inherit pkgs lib; }).options.theme.colors.default;
  files = import ./files.nix { inherit pkgs lib colors; };
  notifier = import ./notifier.nix { inherit pkgs; };
  install = lib.concatStringsSep "\n" (
    lib.mapAttrsToList (
      name: file:
      let
        source = file.source or (pkgs.writeText "sketchybar-file" file.text);
      in
      ''
        mkdir -p "$out/$(dirname '${name}')"
        cp -L ${source} "$out/${name}"
        if [ -x ${source} ] || [ "${if file.executable or false then "yes" else "no"}" = yes ]; then
          chmod 755 "$out/${name}"
        else chmod 644 "$out/${name}"; fi
      ''
    ) files
  );
in
pkgs.runCommand "sketchybar-config" { } ''
  (
    cd ${../..}
    for fixture in probe widgets spaces refresh calendar; do
      ${pkgs.lua55Packages.lua}/bin/lua "tests/sketchybar-$fixture.lua"
    done
  )
  ${install}
  grep -F 'sketchybar_generation =' "$out/.config/sketchybar/sketchybarrc" >/dev/null
  mkdir -p "$out/bin"
  ln -s ${notifier} "$out/bin/aerospace-notify"
  ${pkgs.lua55Packages.lua}/bin/luac -p "$out/.config/sketchybar/"*.lua "$out/.config/sketchybar/"{items,helpers}/*.lua
''
