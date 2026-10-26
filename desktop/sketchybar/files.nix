{
  pkgs,
  lib,
  colors,
}:
let
  c = colors;
  fingerprint = builtins.hashString "sha256" (
    builtins.toJSON colors
    + builtins.readFile ../workspaces.json
    + lib.concatMapStrings builtins.readFile (lib.filesystem.listFilesRecursive ./.)
  );
  toArgb = hex: "0xff${builtins.substring 1 6 hex}";
  toArgbAlpha = alpha: hex: "0x${alpha}${builtins.substring 1 6 hex}";

  inherit (pkgs.lua55Packages) lua;
  sbarlua = import ./sbarlua.nix { inherit pkgs; };
  inherit (import ./native.nix { inherit pkgs; }) menu metrics processStamp;

  luaFile = path: { source = path; };
  workspaceKeys = builtins.fromJSON (builtins.readFile ../workspaces.json);
in
{
  ".local/bin/desktop-metrics".source = "${metrics}/bin/desktop-metrics";
  ".local/bin/desktop-network".source = "${metrics}/bin/desktop-network";
  ".local/bin/desktop-audio".source = "${metrics}/bin/desktop-audio";
  ".local/bin/desktop-probe" = {
    executable = true;
    text = ''
      #!/bin/sh
      exec ${pkgs.coreutils}/bin/timeout --signal=TERM --kill-after=1 4 /bin/sh -c "$1"
    '';
  };
  ".config/sketchybar/helpers/processstamp.so".source = "${processStamp}/lib/processstamp.so";
  ".config/sketchybar/helpers/native-menu".source = "${menu}/bin/desktop-menu";
  ".config/sketchybar/helpers/menu-client".source = "${menu}/bin/menu-client";
  # Lua bootstrap (executed by sketchybar)
  ".config/sketchybar/sketchybarrc" = {
    executable = true;
    text = ''
      #!${lua}/bin/lua
      package.cpath = package.cpath .. ";${sbarlua}/lib/lua/${lua.luaversion}/?.so"

      local config_dir = os.getenv("HOME") .. "/.config/sketchybar"
      package.cpath = config_dir .. "/helpers/?.so;" .. package.cpath
      package.path = config_dir .. "/?.lua;"
        .. config_dir .. "/?/init.lua;"
        .. package.path

      local generation_file = assert(io.open(config_dir .. "/generation-id", "r"))
      sketchybar_generation = generation_file:read("*l")
      generation_file:close()
      require("init")
    '';
  };

  ".config/sketchybar/workspaces.lua".text =
    "return { " + lib.concatMapStringsSep ", " builtins.toJSON workspaceKeys + " }\n";

  # Colors (generated from Stylix theme)
  ".config/sketchybar/colors.lua".text = ''
    local M = {}

    M.black = ${toArgb c.base}
    M.white = ${toArgb c.text}
    M.red = ${toArgb c.red}
    M.green = ${toArgb c.green}
    M.teal = ${toArgb c.teal}
    M.sky = ${toArgb c.sky}
    M.sapphire = ${toArgb c.sapphire}
    M.blue = ${toArgb c.blue}
    M.lavender = ${toArgb c.lavender}
    M.yellow = ${toArgb c.yellow}
    M.peach = ${toArgb c.peach}
    M.pink = ${toArgb c.pink}
    M.mauve = ${toArgb c.mauve}
    M.grey = ${toArgb c.overlay0}
    M.surface = ${toArgb c.surface0}
    M.pure_white = 0xffffffff
    M.transparent = 0x00000000

    M.bar = {
      bg = ${toArgbAlpha "4d" c.base},
      border = ${toArgb c.base},
    }
    M.popup = {
      bg = ${toArgbAlpha "c0" c.base},
      border = ${toArgb c.overlay0},
    }
    M.bg1 = ${toArgb c.surface0}
    M.bg2 = ${toArgb c.surface1}

    M.with_alpha = function(color, alpha)
      if alpha > 1.0 or alpha < 0.0 then return color end
      return (color & 0x00ffffff) | (math.floor(alpha * 255.0) << 24)
    end

    return M
  '';

  ".config/sketchybar/generation-id".text = fingerprint + "\n";

  # Lua source files
  ".config/sketchybar/init.lua" = luaFile ./init.lua;
  ".config/sketchybar/bar.lua" = luaFile ./bar.lua;
  ".config/sketchybar/icons.lua" = luaFile ./icons.lua;
  ".config/sketchybar/settings.lua" = luaFile ./settings.lua;
  ".config/sketchybar/default.lua" = luaFile ./default.lua;

  # Items
  ".config/sketchybar/items/init.lua" = luaFile ./items/init.lua;
  ".config/sketchybar/items/spaces.lua" = luaFile ./items/spaces.lua;
  ".config/sketchybar/items/front_app.lua" = luaFile ./items/front_app.lua;
  ".config/sketchybar/items/calendar.lua" = luaFile ./items/calendar.lua;
  ".config/sketchybar/items/media.lua" = luaFile ./items/media.lua;
  ".config/sketchybar/items/battery.lua" = luaFile ./items/battery.lua;
  ".config/sketchybar/items/volume.lua" = luaFile ./items/volume.lua;
  ".config/sketchybar/items/wifi.lua" = luaFile ./items/wifi.lua;
  ".config/sketchybar/items/cpu.lua" = luaFile ./items/cpu.lua;
  ".config/sketchybar/items/memory.lua" = luaFile ./items/memory.lua;
  ".config/sketchybar/items/metrics.lua" = luaFile ./items/metrics.lua;

  # Helpers
  ".config/sketchybar/helpers/app_icons.lua" = luaFile ./helpers/app_icons.lua;
  ".config/sketchybar/helpers/shell.lua" = luaFile ./helpers/shell.lua;
  ".config/sketchybar/helpers/menu.lua" = luaFile ./helpers/menu.lua;
  ".config/sketchybar/helpers/diagnostics.lua" = luaFile ./helpers/diagnostics.lua;
  ".config/sketchybar/helpers/probe.lua" = luaFile ./helpers/probe.lua;
  ".config/sketchybar/helpers/power.lua" = luaFile ./helpers/power.lua;
  ".config/sketchybar/helpers/network.sh" = luaFile ./helpers/network.sh;
}
