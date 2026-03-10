{ config, ... }:

let
  c = config.home-manager.users.${config.system.primaryUser}.theme.colors;
  toArgb = hex: "0xff${builtins.substring 1 6 hex}";

  plugin = path: {
    executable = true;
    source = path;
  };
in
{
  home-manager.users.${config.system.primaryUser}.home.file = {
    # Color definitions (needs Nix interpolation for theme colors)
    ".config/sketchybar/plugins/colors.sh" = {
      executable = true;
      text = ''
        #!/bin/bash
        export BLACK=${toArgb c.base}
        export WHITE=${toArgb c.text}
        export RED=${toArgb c.red}
        export GREEN=${toArgb c.green}
        export TEAL=${toArgb c.teal}
        export SKY=${toArgb c.sky}
        export SAPPHIRE=${toArgb c.sapphire}
        export BLUE=${toArgb c.blue}
        export LAVENDER=${toArgb c.lavender}
        export YELLOW=${toArgb c.yellow}
        export PEACH=${toArgb c.peach}
        export PINK=${toArgb c.pink}
        export MAUVE=${toArgb c.mauve}
        export GREY=${toArgb c.overlay0}
        export SURFACE=${toArgb c.surface0}
        export TRANSPARENT=0x00000000
      '';
    };

    # Main config and plugins (all raw shell files)
    ".config/sketchybar/sketchybarrc" = plugin ./sketchybarrc;
    ".config/sketchybar/plugins/aerospace.sh" = plugin ./plugins/aerospace.sh;
    ".config/sketchybar/plugins/icon_map.sh" = plugin ./plugins/icon_map.sh;
    ".config/sketchybar/plugins/front_app.sh" = plugin ./plugins/front_app.sh;
    ".config/sketchybar/plugins/clock.sh" = plugin ./plugins/clock.sh;
    ".config/sketchybar/plugins/date.sh" = plugin ./plugins/date.sh;
    ".config/sketchybar/plugins/media.sh" = plugin ./plugins/media.sh;
    ".config/sketchybar/plugins/battery.sh" = plugin ./plugins/battery.sh;
    ".config/sketchybar/plugins/volume.sh" = plugin ./plugins/volume.sh;
    ".config/sketchybar/plugins/wifi.sh" = plugin ./plugins/wifi.sh;
    ".config/sketchybar/plugins/cpu.sh" = plugin ./plugins/cpu.sh;
    ".config/sketchybar/plugins/memory.sh" = plugin ./plugins/memory.sh;
  };
}
