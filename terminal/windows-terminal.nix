# Windows Terminal configuration (generated from theme.colors)
{
  config,
  lib,
  ...
}:

let
  cfg = config.programs.windows-terminal;
  inherit (config.theme) colors;
  fonts = config.stylix.fonts or { };

  # Convert theme colors to Windows Terminal scheme
  colorScheme = {
    name = "Catppuccin Mocha";
    background = colors.base;
    foreground = colors.text;
    cursorColor = colors.rosewater;
    selectionBackground = colors.surface2;
    black = colors.surface1;
    brightBlack = colors.surface2;
    inherit (colors) red;
    brightRed = colors.red;
    inherit (colors) green;
    brightGreen = colors.green;
    inherit (colors) yellow;
    brightYellow = colors.yellow;
    inherit (colors) blue;
    brightBlue = colors.blue;
    purple = colors.pink;
    brightPurple = colors.pink;
    cyan = colors.teal;
    brightCyan = colors.teal;
    white = colors.subtext1;
    brightWhite = colors.subtext0;
  };

  defaultSettings = {
    "$help" = "https://aka.ms/terminal-documentation";
    "$schema" = "https://aka.ms/terminal-profiles-schema";
    defaultProfile = "{2c4de342-38b7-51cf-b940-2309a097f518}";
    copyOnSelect = true;
    copyFormatting = "none";

    profiles = {
      defaults = {
        colorScheme = colorScheme.name;
        font = {
          face = fonts.monospace.name or "JetBrainsMono Nerd Font";
          size = fonts.sizes.terminal or 12;
        };
        padding = "8";
        scrollbarState = "hidden";
        antialiasingMode = "cleartype";
        cursorShape = "bar";
        opacity = builtins.floor ((config.stylix.opacity.terminal or 0.95) * 100);
        useAcrylic = (config.stylix.opacity.terminal or 1.0) < 1.0;
      };
      list = [
        {
          guid = "{2c4de342-38b7-51cf-b940-2309a097f518}";
          name = "Ubuntu";
          source = "Windows.Terminal.Wsl";
          startingDirectory = "~";
        }
        {
          guid = "{574e775e-4f2a-5b96-ac1e-a2962a402336}";
          name = "PowerShell";
          source = "Windows.Terminal.PowershellCore";
          hidden = false;
        }
        {
          guid = "{0caa0dad-35be-5f56-a8ff-afceeeaa6101}";
          name = "Command Prompt";
          commandline = "%SystemRoot%\\System32\\cmd.exe";
          hidden = true;
        }
      ];
    };

    schemes = [ colorScheme ];

    actions = [
      {
        command = {
          action = "copy";
          singleLine = false;
        };
        keys = "ctrl+shift+c";
      }
      {
        command = "paste";
        keys = "ctrl+shift+v";
      }
      {
        command = "find";
        keys = "ctrl+shift+f";
      }
      {
        command = {
          action = "splitPane";
          split = "down";
        };
        keys = "ctrl+q -";
      }
      {
        command = {
          action = "splitPane";
          split = "right";
        };
        keys = "ctrl+q |";
      }
      {
        command = "closePane";
        keys = "ctrl+q x";
      }
      {
        command = "togglePaneZoom";
        keys = "ctrl+q z";
      }
      {
        command = {
          action = "moveFocus";
          direction = "left";
        };
        keys = "ctrl+q h";
      }
      {
        command = {
          action = "moveFocus";
          direction = "down";
        };
        keys = "ctrl+q j";
      }
      {
        command = {
          action = "moveFocus";
          direction = "up";
        };
        keys = "ctrl+q k";
      }
      {
        command = {
          action = "moveFocus";
          direction = "right";
        };
        keys = "ctrl+q l";
      }
      {
        command = {
          action = "resizePane";
          direction = "left";
        };
        keys = "ctrl+q shift+h";
      }
      {
        command = {
          action = "resizePane";
          direction = "down";
        };
        keys = "ctrl+q shift+j";
      }
      {
        command = {
          action = "resizePane";
          direction = "up";
        };
        keys = "ctrl+q shift+k";
      }
      {
        command = {
          action = "resizePane";
          direction = "right";
        };
        keys = "ctrl+q shift+l";
      }
      {
        command = {
          action = "newTab";
        };
        keys = "ctrl+t";
      }
      {
        command = {
          action = "closeTab";
        };
        keys = "ctrl+w";
      }
      {
        command = {
          action = "prevTab";
        };
        keys = "ctrl+shift+tab";
      }
      {
        command = {
          action = "nextTab";
        };
        keys = "ctrl+tab";
      }
      {
        command = {
          action = "switchToTab";
          index = 0;
        };
        keys = "ctrl+1";
      }
      {
        command = {
          action = "switchToTab";
          index = 1;
        };
        keys = "ctrl+2";
      }
      {
        command = {
          action = "switchToTab";
          index = 2;
        };
        keys = "ctrl+3";
      }
      {
        command = {
          action = "switchToTab";
          index = 3;
        };
        keys = "ctrl+4";
      }
      {
        command = {
          action = "switchToTab";
          index = 4;
        };
        keys = "ctrl+5";
      }
    ];
  };
in
{
  options.programs.windows-terminal = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = config.platform.os == "windows";
      description = "Windows Terminal configuration (auto-enabled for Windows)";
    };

    settings = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = "Additional settings to merge with defaults";
    };
  };

  config = lib.mkIf cfg.enable {
    # Generate settings.json in home-files for deployment
    xdg.configFile."windows-terminal/settings.json".text = builtins.toJSON (
      lib.recursiveUpdate defaultSettings cfg.settings
    );
  };
}
