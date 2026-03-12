{ config, pkgs, ... }:

let
  c = config.home-manager.users.${config.system.primaryUser}.theme.colors;
  toArgb = hex: "0xff${builtins.substring 1 6 hex}";

  lua = pkgs.lua5_4;
  inherit (pkgs) sbarlua;

  luaFile = path: { source = path; };
in
{
  home-manager.users.${config.system.primaryUser} = {
    home.packages = [ lua ];

    home.file = {
      # Lua bootstrap (executed by sketchybar)
      ".config/sketchybar/sketchybarrc" = {
        executable = true;
        text = ''
          #!${lua}/bin/lua
          package.cpath = package.cpath .. ";${sbarlua}/lib/lua/5.4/?.so"

          local config_dir = os.getenv("HOME") .. "/.config/sketchybar"
          package.path = config_dir .. "/?.lua;"
            .. config_dir .. "/?/init.lua;"
            .. package.path

          require("init")
        '';
      };

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
        M.transparent = 0x00000000

        function M.with_alpha(color, alpha)
          return (color & 0x00ffffff) | (alpha << 24)
        end

        return M
      '';

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

      # Helpers
      ".config/sketchybar/helpers/app_icons.lua" = luaFile ./helpers/app_icons.lua;
    };
  };
}
