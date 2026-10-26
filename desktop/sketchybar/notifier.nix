{ pkgs }:
let
  inherit (pkgs.lua55Packages) lua;
  inherit (import ./native.nix { inherit pkgs; }) processStamp;
  sbarlua = import ./sbarlua.nix { inherit pkgs; };
  workspaceNotifier = pkgs.writeScript "aerospace-notify" ''
    #!${lua}/bin/lua
    package.cpath = "${processStamp}/lib/?.so;${sbarlua}/lib/lua/${lua.luaversion}/?.so;" .. package.cpath
    local notify = (function()
      ${builtins.readFile ../aerospace-notify.lua}
    end)()
    notify.run(os.getenv("AEROSPACE_FOCUSED_WORKSPACE"), require("processstamp").birth(), require("sketchybar").trigger)
  '';
in
workspaceNotifier
