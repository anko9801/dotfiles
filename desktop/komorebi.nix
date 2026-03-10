# Komorebi tiling window manager (WHM module)
# Migrated from system/windows/komorebi.json
_:
let
  # Catppuccin Mocha subset (matches theme/catppuccin-mocha.nix)
  colors = {
    blue = "#89b4fa";
    green = "#a6e3a1";
    yellow = "#f9e2af";
    surface1 = "#45475a";
  };
in
{
  programs.komorebi = {
    enable = true;
    settings = {
      app_specific_configuration_path = "$Env:USERPROFILE/.config/komorebi/applications.json";
      window_hiding_behaviour = "Cloak";
      cross_monitor_move_behaviour = "Insert";
      default_workspace_padding = 6;
      default_container_padding = 6;
      border = true;
      border_width = 2;
      border_offset = -1;
      border_colours = {
        single = colors.blue;
        stack = colors.green;
        monocle = colors.yellow;
        unfocused = colors.surface1;
      };
      stackbar = {
        mode = "OnStack";
        height = 24;
        label = "Title";
      };
      monitors = [
        {
          workspaces = [
            {
              name = "1";
              layout = "BSP";
            }
            {
              name = "2";
              layout = "BSP";
            }
            {
              name = "3";
              layout = "BSP";
            }
            {
              name = "4";
              layout = "BSP";
            }
            {
              name = "5";
              layout = "BSP";
            }
            {
              name = "6";
              layout = "VerticalStack";
            }
            {
              name = "7";
              layout = "VerticalStack";
            }
            {
              name = "8";
              layout = "VerticalStack";
            }
            {
              name = "9";
              layout = "Monocle";
            }
          ];
        }
      ];
    };
  };
}
