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
    copyOnSelect = false;
    copyFormatting = "none";
    language = "ja";

    profiles = {
      defaults = {
        colorScheme = colorScheme.name;
        font = {
          face = fonts.monospace.name or "Moralerspace Neon";
          size = 9;
        };
        padding = "0";
        antialiasingMode = "grayscale";
        cursorShape = "bar";
      };
      list = [
        # WSL
        {
          guid = "{2c4de342-38b7-51cf-b940-2309a097f518}";
          name = "Ubuntu";
          source = "Windows.Terminal.Wsl";
          startingDirectory = "~";
        }
        # PowerShell
        {
          guid = "{574e775e-4f2a-5b96-ac1e-a2962a402336}";
          name = "PowerShell";
          source = "Windows.Terminal.PowershellCore";
          hidden = false;
        }
        {
          guid = "{e7f51a44-2e34-4157-879f-1284f9841f09}";
          name = "Windows PowerShell";
          commandline = "%SystemRoot%\\System32\\WindowsPowerShell\\v1.0\\powershell.exe";
          hidden = false;
        }
        {
          guid = "{61c54bbd-c2c6-5271-96e7-009a87ff44bf}";
          name = "Windows PowerShell (Administrator)";
          commandline = "%SystemRoot%\\System32\\WindowsPowerShell\\v1.0\\powershell.exe";
          elevate = true;
          hidden = false;
        }
        # Command Prompt
        {
          guid = "{0caa0dad-35be-5f56-a8ff-afceeeaa6101}";
          name = "Command Prompt";
          commandline = "%SystemRoot%\\System32\\cmd.exe";
          hidden = false;
        }
        {
          guid = "{12f1be4c-6e7c-4897-8343-f8402f539b26}";
          name = "Command Prompt (Administrator)";
          commandline = "%SystemRoot%\\System32\\cmd.exe";
          elevate = true;
          hidden = false;
        }
      ];
    };

    schemes = [ colorScheme ];

    # Command definitions (id-based)
    actions = [
      {
        command = {
          action = "copy";
          singleLine = false;
        };
        id = "User.copy";
      }
      {
        command = "paste";
        id = "User.paste";
      }
      {
        command = "find";
        id = "User.find";
      }
      {
        command = {
          action = "splitPane";
          split = "down";
        };
        id = "User.splitPane.down";
      }
      {
        command = {
          action = "splitPane";
          split = "right";
        };
        id = "User.splitPane.right";
      }
      {
        command = "closePane";
        id = "User.closePane";
      }
      {
        command = "togglePaneZoom";
        id = "User.togglePaneZoom";
      }
      {
        command = {
          action = "moveFocus";
          direction = "left";
        };
        id = "User.moveFocus.left";
      }
      {
        command = {
          action = "moveFocus";
          direction = "down";
        };
        id = "User.moveFocus.down";
      }
      {
        command = {
          action = "moveFocus";
          direction = "up";
        };
        id = "User.moveFocus.up";
      }
      {
        command = {
          action = "moveFocus";
          direction = "right";
        };
        id = "User.moveFocus.right";
      }
      {
        command = {
          action = "resizePane";
          direction = "left";
        };
        id = "User.resizePane.left";
      }
      {
        command = {
          action = "resizePane";
          direction = "down";
        };
        id = "User.resizePane.down";
      }
      {
        command = {
          action = "resizePane";
          direction = "up";
        };
        id = "User.resizePane.up";
      }
      {
        command = {
          action = "resizePane";
          direction = "right";
        };
        id = "User.resizePane.right";
      }
      {
        command = {
          action = "newTab";
        };
        id = "User.newTab";
      }
      {
        command = {
          action = "closeTab";
        };
        id = "User.closeTab";
      }
      {
        command = {
          action = "prevTab";
        };
        id = "User.prevTab";
      }
      {
        command = {
          action = "nextTab";
        };
        id = "User.nextTab";
      }
      {
        command = {
          action = "switchToTab";
          index = 0;
        };
        id = "User.switchToTab.0";
      }
      {
        command = {
          action = "switchToTab";
          index = 1;
        };
        id = "User.switchToTab.1";
      }
      {
        command = {
          action = "switchToTab";
          index = 2;
        };
        id = "User.switchToTab.2";
      }
      {
        command = {
          action = "switchToTab";
          index = 3;
        };
        id = "User.switchToTab.3";
      }
      {
        command = {
          action = "switchToTab";
          index = 4;
        };
        id = "User.switchToTab.4";
      }
    ];

    # Key bindings (reference actions by id)
    keybindings = [
      {
        id = "User.copy";
        keys = "ctrl+shift+c";
      }
      {
        id = "User.paste";
        keys = "ctrl+shift+v";
      }
      {
        id = "User.find";
        keys = "ctrl+shift+f";
      }
      {
        id = "User.splitPane.down";
        keys = "ctrl+q -";
      }
      {
        id = "User.splitPane.right";
        keys = "ctrl+q |";
      }
      {
        id = "User.closePane";
        keys = "ctrl+q x";
      }
      {
        id = "User.togglePaneZoom";
        keys = "ctrl+q z";
      }
      {
        id = "User.moveFocus.left";
        keys = "ctrl+q h";
      }
      {
        id = "User.moveFocus.down";
        keys = "ctrl+q j";
      }
      {
        id = "User.moveFocus.up";
        keys = "ctrl+q k";
      }
      {
        id = "User.moveFocus.right";
        keys = "ctrl+q l";
      }
      {
        id = "User.resizePane.left";
        keys = "ctrl+q shift+h";
      }
      {
        id = "User.resizePane.down";
        keys = "ctrl+q shift+j";
      }
      {
        id = "User.resizePane.up";
        keys = "ctrl+q shift+k";
      }
      {
        id = "User.resizePane.right";
        keys = "ctrl+q shift+l";
      }
      {
        id = "User.newTab";
        keys = "ctrl+t";
      }
      {
        id = "User.closeTab";
        keys = "ctrl+w";
      }
      {
        id = "User.prevTab";
        keys = "ctrl+shift+tab";
      }
      {
        id = "User.nextTab";
        keys = "ctrl+tab";
      }
      {
        id = "User.switchToTab.0";
        keys = "ctrl+1";
      }
      {
        id = "User.switchToTab.1";
        keys = "ctrl+2";
      }
      {
        id = "User.switchToTab.2";
        keys = "ctrl+3";
      }
      {
        id = "User.switchToTab.3";
        keys = "ctrl+4";
      }
      {
        id = "User.switchToTab.4";
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
